---
name: dashboard-guide
description: Design, build and review secure operational dashboards: UI design, KPI cards, charts, dependent filters, tables, drilldowns, CSV exports, security checks. Use for any dashboard work.
---

# Dashboard Guide

Build dashboards that help people **decide and act**, look consistent across projects, and
never leak data. This applies to every dashboard: new, changed, debugged or reviewed. It covers
Vue + frappe-ui, Frappe desk pages and plain HTML.

| Read | When |
|---|---|
| [references/ui-design.md](references/ui-design.md) | **Always** before designing or changing the UI: layout, KPI cards, chart choice, colour, numbers, states, responsive, accessibility |
| [references/dashboard-review-checklist.md](references/dashboard-review-checklist.md) | Before handing over or approving any dashboard |
| [templates/](templates/) | Vue + frappe-ui 1.2.0 projects: ready page, filter composable, service and backend |

## Golden rules

1. **Match the existing style.** If the project has dashboards, reuse their layout, card and
   filter patterns. Don't redesign unless asked; ask when "match vs improve" is unclear.
2. **Every block answers a question** someone acts on. No decorative numbers.
3. **Useful on first load.** Sensible defaults (e.g. this month, all permitted records), never
   a blank "select filters first" screen.
4. **One applied filter state** drives every card, chart, table, drilldown and export, so all
   numbers on the page agree.
5. **The server decides access** for every number, option, row and file. Hiding in the UI
   protects nothing.
6. **Never fake data.** On failure, show the error and a retry, not zeros or stale numbers
   presented as current.

## 1. Understand before building
- Identify the users, their roles and the decisions the dashboard supports.
- Inspect the existing code, DocTypes, fields, APIs and permissions. **Don't invent fields,
  metrics, business rules or endpoints.**
- For every metric, write down: source fields, calculation, period, filter behaviour, who may
  see it, and what the user does next (the drilldown).

## 2. Layout and UI design
Four zones, top to bottom: **Header** (title, scope sentence, last updated) → **Filters** →
**KPIs** (3–6) → **Detail** (charts + "needs action" table). Full rules and diagrams are in
[references/ui-design.md](references/ui-design.md). The essentials:

- Reading order = importance order. Put "needs action" before "nice to know".
- Every number has a **unit, period and comparison**. Delta colour follows meaning
  (`negativeIsBetter` for overdue or pending).
- **Choose the chart by the question:** a trend over time is a line, ranking categories is a
  sorted horizontal bar, and share of a whole (≤ 5 parts) is a donut. No 3D, no pies with > 5
  slices, and bars start at zero.
- **Gray first, colour for meaning.** Status colours keep fixed meanings app-wide, and colour
  is never the only signal.
- **Numbers:** tabular figures, right-aligned in tables, locale formatting, `—` for no data.
- **States per block:** skeleton on first load, dimmed old data while refreshing, empty with
  reason, error with retry, partial-data warning.
- **Responsive:** KPIs 4 → 2 per row, charts stack, tables scroll inside their box, filters
  move into a sheet. Grid cells holding charts need `min-w-0`.
- **Accessible:** clickable cards are real buttons, focus rings stay visible, charts have a
  text summary.

## 3. Filters
- Group filters at the top, ordered from the broadest to the narrowest: period → org level →
  category → status.
- Offer multi-select, select all, clear, search within options, **Apply**, **Reset**, and
  visible removable active-filter chips.
- **Draft vs applied:** changing a control fetches nothing. **Apply** fetches once with all
  values ("Apply 2 changes" shows unapplied edits). Auto-refresh only for a single simple
  filter, debounced.
- **Dependent filters** (State → District → Block): child options follow the selected parents.
  When a parent changes, remove child selections that are no longer valid. The server
  validates the relationship too.
- Filter options are **permission-aware**, so users never see values they can't access.
- Mark metrics that ignore filters as "All time".
- Vue template: `templates/useDashboardFilters.js` (draft/applied, dirty count, chips,
  dependent clean-up; unit-tested).

## 4. KPI cards, charts, tables
- **KPIs:** 3–6. Each has a clear label, value, unit, period and comparison, and a drilldown
  when the user would ask "which ones?".
- **Charts:** one question each, titled as the question, units labelled, ≤ 6 colours, the
  same category in the same colour on every chart.
- **Tables:** title with count ("Overdue requests (38)"), 5–8 columns, a default sort that
  answers the question, top 10–20 rows with "View all" into the drilldown.
- **Aggregate on the server.** Never download all records to count them in the browser.

## 5. Drilldowns
- Every KPI, chart bar or row that invites "which ones?" opens a drilldown with **the same
  applied filters plus the clicked bucket**.
- Use a centred dialog with its title repeating the metric, active filters, a result count,
  sortable columns, **server pagination** and Export CSV. Only the body scrolls.
- Closing returns the dashboard exactly as it was.
- The drilldown endpoint enforces the same permissions as the KPI, and accepts only known
  bucket names.

## 6. CSV exports
- Export the authorised result set for the active filters. Re-check permission (including the
  `export` permission) on the server at export time.
- **Block formula injection:** prefix cells that start with `= + - @ \t \r` with `'`.
- Clear headers, consistent date and number formats, and a row cap with a message when it's
  hit.

## 7. Security: mandatory every time
**Run a security review for every dashboard change, including "just visual" ones.**

**Client:**
- No `v-html` / `innerHTML` with record values, labels or error text. Validate URLs built from
  data.
- No secrets, keys or restricted data in frontend code, URLs, local storage or logs.
- Hidden cards, columns and buttons (CSS or `v-if`) are UX only, never access control.

**Server**, for every path (KPIs, charts, tables, filter options, drilldowns, record details,
exports):
- Authenticate and authorise. Respect roles, User Permissions, record and field restrictions.
- Use `frappe.get_list` (permission-aware) for user-facing data. Custom SQL and `get_all` do
  **not** apply permissions, so add the conditions yourself if you must use them.
- Validate filters, IDs, dates and page sizes. **Allowlist** sort fields and bucket names, and
  use parameters only (no string-built SQL).
- Counts, aggregates and filter options must not reveal restricted records.
- Errors don't expose internals.

**Verify** with at least one full-access and one restricted user, plus direct API calls with
manipulated filters and IDs. Report findings by severity. **Never claim "secure" without having
inspected the code and run the checks.**

## 8. Performance and reliability
- Load KPIs first, then charts and tables in parallel, each with its own loading state.
- One request per Apply per block. Discard stale responses (frappe-ui `useCall` keeps only the
  newest).
- Paginate large sets. Cache filter options.
- Handle partial failures per block. Keep card, chart, table and drilldown calculations on the
  same server filter function.

## 9. Vue + frappe-ui 1.2.0 implementation

Use with the `vue-architecture`, `vue-common-components` and `frappe-ui` skills.

| Need | Use |
|---|---|
| KPI card | `NumberCard` (`frappe-ui/charts`) inside a `<button>` for drilldown; `value: null` shows "no data" |
| Charts | `BarChart` (`horizontal` for rankings), `LineChart`, `DonutChart`, … with `:data`, `x`/`y` or `category`/`value`, `title`, `loading`, `error`; height on the wrapper (`h-72`/`h-80`); `@select` → drilldown |
| Filters | `DateRangePicker`, `MultiSelect`, `Select` + `templates/useDashboardFilters.js` |
| Tables / drilldown | team `DataTable` + `Dialog` with server paging (see `templates/DashboardPage.vue`) |
| Data | `templates/dashboard.service.js` (useCall; filters sent as one JSON string) |
| Backend | `templates/dashboard_api.py`: one `_base_filters()` shared by `get_dashboard`, `get_drilldown`, `export_drilldown`; works on Frappe v15 and v16 |

Charts draw their own title, legend, loading, error and empty states, so don't wrap them in
extra cards or spinners.

**`yarn dev` with frappe-ui 1.2.0:** add `optimizeDeps: { exclude: ['frappe-ui/charts'] }` to
`vite.config.js`, or the dev server fails with `Could not resolve "#utils/debounce"`.
Production builds aren't affected.

## 10. Frappe desk dashboards (no Vue)
- Number Cards: `filters_json` entries use the **4-element** form
  `[doctype, field, operator, value]`. Frappe's JS drops filters that carry a 5th `false`
  element.
- Desk pages: render values with `frappe.utils.escape_html` / `__()`, never raw HTML from data.
  Call whitelisted methods via `frappe.call`, with the same server rules as above.
- Workspaces: don't force re-import a Workspace JSON in developer mode (it can delete the
  folder, and the next migrate removes the workspace).

## 11. Reference examples
When accessible, use as interaction references (don't copy blindly; don't claim to have
inspected one you couldn't open):
- Running journal: http://13.126.167.96/run-journal
- `run-detail.js` page, including its map and supporting statistics
- Network hospital dashboard

## 12. Workflow
1. Inspect the existing code, data, APIs, permissions and dashboard style.
2. Identify users, decisions and the metric definitions (§1).
3. Sketch the four zones and choose a chart per question ([ui-design.md](references/ui-design.md)).
4. Define filters: defaults, dependencies, Apply behaviour.
5. Build the backend: one shared filter function, permission-aware aggregates, drilldown and
   export.
6. Build the UI with states, responsive behaviour and accessibility.
7. Security review (§7), including restricted-user tests.
8. Test filters, calculations, drilldowns, exports, 360/768/1280px widths and dark mode.
9. Run [the checklist](references/dashboard-review-checklist.md).
10. Report: changes, metric definitions, tests run vs pending, security findings, deployment
    steps.

Preserve existing behaviour unless a change is requested. Don't claim tests passed unless they
were run.
