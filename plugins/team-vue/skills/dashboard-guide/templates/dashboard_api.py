# <app>/api/dashboard.py — team template for a dashboard backend (Frappe v15+).
#
# Four endpoints, one shared filter function, so every number on the page agrees:
#   get_filter_options()                       → options for the filter bar (permission-aware)
#   get_dashboard(filters)                     → KPIs + chart rows + top "needs action" rows
#   get_drilldown(bucket, filters, ...)        → paginated records behind one KPI / chart bar
#   export_drilldown(bucket, filters, ...)     → the same records as CSV
#
# Replace DOCTYPE, fields and buckets with your own. Check every field exists in your DocType.
# All reads use frappe.get_list (permission-aware) — never raw SQL built from client input.
# Query shapes verified on Frappe v16.7; v15 handled by _count_field().

import csv
import io

import frappe
from frappe import _
from frappe.utils import add_days, getdate, nowdate

DOCTYPE = "Service Request"  # ← your DocType
ROW_FIELDS = ["name", "subject", "region", "unit", "status", "due_date", "creation"]
SORTABLE = {"creation", "due_date", "status", "subject"}  # allowlist for ORDER BY
MAX_PAGE = 500
MAX_EXPORT = 20000

# bucket name → extra filters. The UI may only ask for these names.
BUCKETS = {
	"all": {},
	"completed": {"status": "Completed"},
	"pending": {"status": ["in", ["Open", "Pending"]]},
	"overdue": {"status": ["in", ["Open", "Pending"]], "due_date": ["<", nowdate()]},
}


# ---------------------------------------------------------------- helpers

# Frappe v16 rejects SQL functions written as strings ("count(*) as n") and needs dict syntax;
# v15 only understands the string form. This keeps the template working on both.
_V16 = int(frappe.__version__.split(".")[0]) >= 16


def _count_field(alias):
	return {"COUNT": "*", "as": alias} if _V16 else f"count(*) as {alias}"


def _require_read():
	if not frappe.has_permission(DOCTYPE, "read"):
		frappe.throw(_("Not permitted"), frappe.PermissionError)


def _as_list(value):
	if value in (None, "", []):
		return []
	return value if isinstance(value, list) else [value]


def _base_filters(filters):
	"""Validate client filters and turn them into Frappe filters. The ONLY place filters are read."""
	f = frappe.parse_json(filters) if isinstance(filters, str) else (filters or {})
	if not isinstance(f, dict):
		frappe.throw(_("Invalid filters"))

	out = {}
	period = _as_list(f.get("period"))
	if period:
		if len(period) != 2:
			frappe.throw(_("Period needs a start and an end date"))
		start, end = getdate(period[0]), getdate(period[1])  # raises on bad dates
		if start > end:
			frappe.throw(_("Start date is after end date"))
		out["creation"] = ["between", [start, add_days(end, 1)]]

	for key in ("region", "unit", "status"):
		values = [str(v) for v in _as_list(f.get(key))][:200]
		if values:
			out[key] = ["in", values]
	return out


def _bucket_filters(bucket, filters):
	if bucket not in BUCKETS:
		frappe.throw(_("Unknown metric"))
	merged = _base_filters(filters)
	merged.update(BUCKETS[bucket])
	return merged


def _count(filters):
	# get_list applies role permissions + User Permissions, so counts never leak hidden records
	return frappe.get_list(DOCTYPE, filters=filters, fields=[_count_field("n")])[0].n or 0


# ---------------------------------------------------------------- endpoints


@frappe.whitelist()
def get_filter_options():
	_require_read()
	units = frappe.get_list(
		DOCTYPE,
		fields=["region", "unit"],
		group_by="region, unit",
		order_by="region asc, unit asc",
		limit_page_length=0,
	)
	regions = sorted({u.region for u in units if u.region})
	return {
		"regions": [{"label": r, "value": r} for r in regions],
		"units": [{"label": u.unit, "value": u.unit, "region": u.region} for u in units if u.unit],
		"statuses": [{"label": s, "value": s} for s in ("Open", "Pending", "Completed", "Cancelled")],
	}


@frappe.whitelist()
def get_dashboard(filters=None):
	_require_read()
	base = _base_filters(filters)

	total = _count(base)
	completed = _count({**base, **BUCKETS["completed"]})
	pending = _count({**base, **BUCKETS["pending"]})
	overdue = _count({**base, **BUCKETS["overdue"]})

	by_status = frappe.get_list(
		DOCTYPE, filters=base, fields=["status", _count_field("count")],
		group_by="status", order_by="count desc",
	)
	by_unit = frappe.get_list(
		DOCTYPE, filters=base, fields=["unit", _count_field("count")],
		group_by="unit", order_by="count desc", limit_page_length=10,
	)
	action_rows = frappe.get_list(
		DOCTYPE, filters={**base, **BUCKETS["overdue"]}, fields=ROW_FIELDS,
		order_by="due_date asc", limit_page_length=10,
	)
	return {
		"as_of": frappe.utils.now(),
		"kpis": {
			"total": total,
			"completion_rate": round(completed * 100.0 / total, 1) if total else None,
			"pending": pending,
			"overdue": overdue,
		},
		"by_status": by_status,
		"by_unit": by_unit,
		"action_rows": action_rows,
		"action_total": overdue,
		"can_export": bool(frappe.has_permission(DOCTYPE, "export")),
	}


@frappe.whitelist()
def get_drilldown(bucket, filters=None, start=0, page_length=50, sort_by="creation", sort_order="desc"):
	_require_read()
	if sort_by not in SORTABLE:
		sort_by = "creation"
	sort_order = "asc" if str(sort_order).lower() == "asc" else "desc"
	start = max(int(start or 0), 0)
	page_length = min(max(int(page_length or 50), 1), MAX_PAGE)

	f = _bucket_filters(bucket, filters)
	return {
		"rows": frappe.get_list(
			DOCTYPE, filters=f, fields=ROW_FIELDS,
			order_by=f"{sort_by} {sort_order}", start=start, page_length=page_length,
		),
		"total": _count(f),
	}


def _csv_safe(value):
	"""Block CSV/formula injection: cells starting with = + - @ tab or CR are prefixed with '."""
	text = "" if value is None else str(value)
	return "'" + text if text[:1] in ("=", "+", "-", "@", "\t", "\r") else text


@frappe.whitelist(methods=["POST"])
def export_drilldown(bucket, filters=None, sort_by="creation", sort_order="desc"):
	_require_read()
	if not frappe.has_permission(DOCTYPE, "export"):
		frappe.throw(_("Not permitted to export"), frappe.PermissionError)
	if sort_by not in SORTABLE:
		sort_by = "creation"
	sort_order = "asc" if str(sort_order).lower() == "asc" else "desc"

	f = _bucket_filters(bucket, filters)
	rows = frappe.get_list(
		DOCTYPE, filters=f, fields=ROW_FIELDS,
		order_by=f"{sort_by} {sort_order}", limit_page_length=MAX_EXPORT,
	)
	buf = io.StringIO()
	writer = csv.writer(buf)
	writer.writerow([frappe.unscrub(c) for c in ROW_FIELDS])
	for r in rows:
		writer.writerow([_csv_safe(r.get(c)) for c in ROW_FIELDS])

	frappe.response["type"] = "download"
	frappe.response["filename"] = f"{frappe.scrub(DOCTYPE)}_{bucket}.csv"
	frappe.response["filecontent"] = buf.getvalue()
