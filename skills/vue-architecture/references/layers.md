# Layer Examples (frappe-ui 1.2.0, domain-neutral)

Example feature: **Task** in an app called `myapp`. Replace these with your app, DocType and
fields, and check that every field you use exists in your DocType.

## 1. Backend — `myapp/api/task.py`

```python
import frappe
from frappe import _

DOCTYPE = "Task"
EDITABLE_FIELDS = ("subject", "description", "status", "due_date")  # allow-list


def _get(name, ptype="read"):
	doc = frappe.get_doc(DOCTYPE, name)
	doc.check_permission(ptype)  # never trust the client
	return doc


def _require(ptype="read"):
	if not frappe.has_permission(DOCTYPE, ptype):
		frappe.throw(_("Not permitted"), frappe.PermissionError)


@frappe.whitelist()
def get_tasks(status=None):
	_require("read")
	filters = {"status": status} if status else {}
	rows = frappe.get_list(  # get_list applies user permissions
		DOCTYPE,
		filters=filters,
		fields=["name", "subject", "status", "owner", "due_date", "modified"],
		order_by="modified desc",
		limit_page_length=0,
	)
	# Batch lookup: one query for all owners, not one per row
	owners = list({r.owner for r in rows})
	names = {}
	if owners:
		names = dict(frappe.get_all("User", filters={"name": ["in", owners]},
			fields=["name", "full_name"], as_list=True))
	for r in rows:
		r["owner_name"] = names.get(r.owner) or r.owner
	return {"rows": rows, "can_create": bool(frappe.has_permission(DOCTYPE, "create"))}


@frappe.whitelist()
def get_task(name):
	return _get(name).as_dict()


@frappe.whitelist(methods=["POST"])
def update_task(name, data):
	doc = _get(name, "write")
	data = frappe.parse_json(data) or {}
	for field in EDITABLE_FIELDS:
		if field in data:
			doc.set(field, data[field])
	doc.save()
	return doc.as_dict()
```

## 2. Transport — `src/services/api.js`

Copy [../templates/api.js](../templates/api.js) as-is. It provides:
- `method(path)`: the `/api/v2/method/<path>` URL for `useCall`
- `callMethod(path, params)`: the imperative call, **only outside setup** (stores, guards)
- `downloadMethod(path, params, fallbackName)`: file downloads

## 3. Service — `src/services/tasks.js`

Services are the only place endpoint paths appear. They export **factories** that return
`useCall` instances, so they inherit the rule that **they're called only during setup**.

```js
import { useCall } from 'frappe-ui'
import { method, downloadMethod } from './api'

const M = 'myapp.api.task.'

export const taskApi = {
  // reads: GET, fetch on mount
  list: (options = {}) => useCall({ url: method(M + 'get_tasks'), ...options }),
  get: (options = {}) => useCall({ url: method(M + 'get_task'), ...options }),

  // writes: POST, never auto-run; call .submit(params)
  update: (options = {}) =>
    useCall({ url: method(M + 'update_task'), method: 'POST', immediate: false, ...options }),

  // files: plain async function, fine to call from event handlers
  downloadPdf: (name) => downloadMethod(M + 'download_task_pdf', { name }, `${name}.pdf`),
}
```

## 4. Composable — `src/composables/useTasks.js`

```js
import { toValue } from 'vue'
import { taskApi } from '@/services/tasks'

/** status: a ref, getter or plain value. The list refetches when it changes. */
export function useTasks(status = null) {
  const list = taskApi.list({
    params: () => {
      const s = toValue(status)
      return s ? { status: s } : {}
    },
    refetch: true,
  })

  const update = taskApi.update({
    onSuccess: () => list.reload(),
  })

  return { list, update }
}
```

Plain DocType list with no custom endpoint (useful for simple masters):

```js
import { useList } from 'frappe-ui'

export function useTaskList() {
  return useList({
    doctype: 'Task',
    fields: ['name', 'subject', 'status', 'modified'],
    orderBy: 'modified desc',
    limit: 50, // default is 20; page with list.next()
  })
}
// list.data, list.loading, list.error, list.hasNextPage, list.next(), list.reload()
```

## 5. Page — `src/pages/Tasks.vue`

```vue
<template>
  <div class="mx-auto max-w-4xl space-y-6 px-3 pb-10 pt-5 sm:px-5">
    <div class="flex items-center justify-between gap-2">
      <h1 class="text-2xl-semibold text-ink-gray-9">Tasks</h1>
      <Button
        v-if="list.data?.can_create"
        variant="solid"
        theme="gray"
        icon-left="lucide-plus"
        label="New task"
        :route="{ name: 'TaskNew' }"
      />
    </div>

    <ErrorMessage v-if="list.error" :message="list.error" />

    <DataTable
      :columns="columns"
      :rows="list.data?.rows || []"
      :loading="list.loading"
      :row-route="(row) => ({ name: 'TaskDetail', params: { id: row.name } })"
      empty-title="No tasks yet"
    >
      <template #cell-status="{ value }"><StatusBadge :status="value" /></template>
    </DataTable>
  </div>
</template>

<script setup>
import { Button, ErrorMessage } from 'frappe-ui'
import dayjs from 'dayjs'
import DataTable from '@/components/common/DataTable.vue'
import StatusBadge from '@/components/common/StatusBadge.vue'
import { useTasks } from '@/composables/useTasks'

const { list } = useTasks()

const columns = [
  { key: 'subject', label: 'Subject' },
  { key: 'owner_name', label: 'Owner', width: '12rem' },
  { key: 'status', label: 'Status', width: '9rem' },
  {
    key: 'due_date',
    label: 'Due',
    width: '8rem',
    align: 'right',
    format: (r) => (r.due_date ? dayjs(r.due_date).format('DD MMM YYYY') : ''),
  },
]
</script>
```

### A write with confirmation (detail page)

```vue
<script setup>
import { dialog, toast } from 'frappe-ui'
import { taskApi } from '@/services/tasks'

const props = defineProps({ id: { type: String, required: true } })
const task = taskApi.get({ params: { name: props.id } })
const update = taskApi.update() // created in setup, submitted later

function closeTask() {
  dialog.confirm({
    title: 'Close this task?',
    message: 'It will move to Completed.',
    confirmLabel: 'Close task',
    onConfirm: async () => {
      // A rejection shows inline in the dialog and keeps it open
      await update.submit({ name: props.id, data: { status: 'Completed' } })
      toast.success('Task closed')
      task.reload()
    },
  })
}
</script>
```

## 6. Routes — `src/router/index.js`

```js
import { createRouter, createWebHistory } from 'vue-router'
import { useSessionStore } from '@/stores/session'

const routes = [
  {
    path: '/tasks',
    name: 'Tasks',
    component: () => import('@/pages/Tasks.vue'),
    meta: { requiresAuth: true, audience: 'staff' },
  },
  {
    path: '/tasks/:id',
    name: 'TaskDetail',
    component: () => import('@/pages/TaskDetail.vue'),
    props: true,
    meta: { requiresAuth: true, audience: 'staff' },
  },
]

export const router = createRouter({ history: createWebHistory('/myapp'), routes })

router.beforeEach(async (to) => {
  const session = useSessionStore()
  if (to.meta.requiresAuth && !session.isLoggedIn) {
    window.location.href = `/login?redirect-to=${encodeURIComponent('/myapp' + to.fullPath)}`
    return false
  }
  if (session.isLoggedIn && !session.loaded) await session.fetchAccess()
  if (to.meta.audience === 'staff' && !session.isStaff) return { path: '/' } // UX only
})
```

## 7. Session store — `src/stores/session.js` (capabilities, not roles)

Stores run outside component setup, so they use `callMethod`, not `useCall`.

```js
import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { callMethod } from '@/services/api'

function cookieUser() {
  const cookies = new URLSearchParams(document.cookie.split('; ').join('&'))
  const raw = cookies.get('user_id')
  return raw && raw !== 'Guest' ? decodeURIComponent(raw) : null
}

export const useSessionStore = defineStore('session', () => {
  const user = ref(cookieUser())
  const isLoggedIn = computed(() => !!user.value)

  const access = ref({}) // { is_staff, doctypes: { Task: { read, create, write, delete } } }
  const loaded = ref(false)
  let pending = null

  function fetchAccess(force = false) {
    if (!isLoggedIn.value || (loaded.value && !force)) return Promise.resolve()
    if (!pending) {
      pending = callMethod('myapp.api.access.get_my_access')
        .then((data) => { access.value = data || {} })
        .catch(() => { access.value = {} })
        .finally(() => { loaded.value = true; pending = null })
    }
    return pending
  }

  const isStaff = computed(() => !!access.value.is_staff)
  const can = (doctype, ptype = 'read') => !!access.value.doctypes?.[doctype]?.[ptype]

  return { user, isLoggedIn, loaded, fetchAccess, isStaff, can }
})
```

Backend — `myapp/api/access.py`:

```python
import frappe

UI_DOCTYPES = ("Task", "Project")  # the DocTypes this UI shows
PTYPES = ("read", "create", "write", "delete")


@frappe.whitelist()
def get_my_access():
	user = frappe.session.user
	doctypes = {}
	for dt in UI_DOCTYPES:
		doctypes[dt] = {p: bool(frappe.has_permission(dt, p)) for p in PTYPES}
	return {
		"is_staff": user != "Guest" and frappe.db.get_value("User", user, "user_type") == "System User",
		"doctypes": doctypes,
	}
```

This is app code. Don't paste it into a **Server Script**, because Server Scripts can't use
comprehensions over script variables.
