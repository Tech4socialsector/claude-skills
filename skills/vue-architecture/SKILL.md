---
name: vue-architecture
description: Team standard for Vue 3 + frappe-ui 1.2.0 frontends: folder layout, data flow, access checks, backend rules, scaffolding. Use when adding pages, routes, API calls or a new Vue frontend.
---

# Vue Architecture Standard

This standard applies to every Vue frontend the team builds, whatever the domain. It covers
**structure**, not business logic.

Component APIs, props, slots and design tokens are covered by the **`frappe-ui` skill** (the
official reference, bundled alongside this one). Read it before writing markup. This skill
covers how the team organises code around it.

## Pinned stack (new projects)

| Package | Version |
|---|---|
| `frappe-ui` | **1.2.0** (exact) |
| `vue` | ^3.5 |
| `vue-router` | ^4.5 |
| `pinia` | ^3.0 |
| `vite` | ^7.3 |
| `@vitejs/plugin-vue` | ^6.0 |
| `tailwindcss` | ^3.4, **not v4** |
| Node | ≥ 20.19 |
| Frappe backend | v15+ (needs `/api/v2`) |

## 0. Inspect the project first

1. Find the frontend folder (`<app>/frontend/` or `<app>/desk/`) and read `package.json`.
2. **Check the frappe-ui version:**
   - `1.x` → follow this skill and the `frappe-ui` skill.
   - `0.1.x` (older apps) → many APIs differ. Follow
     [references/legacy-0.1.md](references/legacy-0.1.md). **Don't upgrade frappe-ui as part of
     a feature task.** Upgrading is a separate, planned job.
3. **If the project already has its own established pattern**, stay consistent with it and
   mention any deviation. Don't mass-refactor. New projects follow this standard exactly.
4. Never invent backend methods, DocTypes or fields. Read the backend first.

## 1. Folder layout

```
frontend/src/
  main.js            createApp + router + pinia (+ app.use(FrappeUI) optional)
  App.vue            <FrappeUIProvider> once at the root (toasts + dialogs need it)
  style.css          @import 'frappe-ui/style.css'
  router/index.js    routes + one beforeEach guard
  layouts/           one per audience (e.g. StaffLayout.vue with DesktopShell/Sidebar)
  pages/             one file per route; subfolders per area
  components/
    common/          team shared components → vue-common-components skill
    <feature>/       used by one feature only
  composables/       useFeature.js — wires services into reactive state for pages
  services/          feature.js — the ONLY place that names backend endpoints
    api.js           url helper, imperative call, downloads (templates/api.js)
  stores/            Pinia — cross-page state only (session/access, preferences)
  config/            app constants (status tones, nav items)
  utils/             pure helpers (formatting, validation, notify)
```

## 2. The data flow

```
Page.vue → composables/useX.js → services/x.js (useCall/useList factories) → Frappe /api/v2
```

| Layer | Owns | Must NOT |
|---|---|---|
| **Page** | Layout, wiring components, user events | Contain endpoint strings or raw `fetch` |
| **Component** | Rendering through props and emits | Fetch, unless it's a self-contained widget that takes an ID |
| **Composable** | Combines service calls, derived state, reload-after-write | Hardcode endpoints or touch the DOM |
| **Service** | Endpoint paths + `useCall` options (GET/POST, `immediate`) | Hold state of its own or show UI |
| **api.js** | URL helper, imperative `call`, file downloads | Contain feature logic |
| **Backend** | Permission, validation, query, response shape | Trust anything from the client |

Copy-ready example of each layer: [references/layers.md](references/layers.md).

### frappe-ui data rules (1.x)
- **Reads:** use `useCall` (whitelisted method) or `useList` / `useDoc` (plain DocType access).
  They auto-fetch on mount, and `refetch: true` follows reactive `params`.
- **Writes:** create a `useCall({ method: 'POST', immediate: false })` **in setup**, then
  `await x.submit(params)` inside the event handler. `submit` rejects on failure, so wrap it in
  `try/catch`.
- `useCall`, `useList` and `useDoc` are composables. **Call them only during setup** (in a
  composable or `<script setup>`), never inside an event handler, `setTimeout` or a Pinia action.
- Outside setup (Pinia stores, router guards), use the imperative `callMethod()` from `api.js`.
- `useCall` returns a **reactive** object. Read `x.data`, `x.loading` and `x.error` directly,
  without `.value`. `useDoc` returns `doc`, not `data`.
- Bind `:loading="x.loading"` on buttons and `<ErrorMessage :message="x.error" />` near forms.
- The older `createResource` / `createListResource` still work in 1.x, but **new code uses
  `useCall` / `useList`**.

## 3. Pages and components
- Use `<script setup>` + Composition API only.
- **Size limits:** pages ≤ 400 lines, components ≤ 300 lines. Extract sections into
  `components/<feature>/`.
- Every data view has **loading** (`Skeleton` on first load), **error** (`ErrorMessage`) and
  **empty** (`EmptyState`) states.
- Lazy-load routes with `component: () => import('@/pages/X.vue')`. Detail routes use
  `props: true`.
- **Styling:** semantic tokens only (`bg-surface-*`, `text-ink-*`, `border-outline-*`, numbered
  `rounded-*`). Raw Tailwind palette classes (`bg-gray-100`) don't flip in dark mode. No hex
  colours, and no `<style>` unless unavoidable.
- **Icons:** use `lucide-*` classes (`<span class="lucide-plus size-4" aria-hidden="true" />`),
  or `icon="lucide-plus"` on components. Don't use `FeatherIcon`, which was removed in 1.x.
- **Responsive:** works at 360px width with no horizontal page scroll. See the `frappe-ui`
  skill's "Mobile" section.

## 4. State
- **Pinia only for cross-page state**: the session user, access map and preferences. Feature
  data lives in composables or in frappe-ui's shared document store (`useDoc`/`useList` share
  rows automatically).

## 5. Routing and access
- Mark routes with `meta`, e.g. `{ requiresAuth: true, audience: 'staff' }`.
- One `router.beforeEach` handles the login redirect (`/login?redirect-to=...`), loading access
  once, and the audience check.
- The UI asks about **capabilities**, not roles: `session.can('Task', 'create')`,
  `session.isStaff`. These come from one backend call (`get_my_access`) derived from Frappe
  permissions. **Never hardcode role names in Vue.**
- **Guards and hidden buttons are UX only.** Every endpoint enforces permission itself.

## 6. Errors and feedback
- **Toasts:** `toast.success('Saved')` reports what already happened. For errors, use
  `notify.error(err)` from `utils/notify.js`, which extracts a readable message from any
  error shape.
- **Confirmations:** `dialog.confirm({...})` / `dialog.danger({...})` from frappe-ui. Its
  `onConfirm` may be async; a rejection shows inline and keeps the dialog open.
- Never swallow errors. Each one either shows in the UI or is re-thrown.

## 7. Backend rules (Frappe)
- One module per feature: `<app>/api/<feature>.py`. Put private helpers (`_get`, `_require`) at
  the top.
- Every `@frappe.whitelist()` **starts with a permission check**: `doc.check_permission(ptype)`,
  `frappe.has_permission(...)` or `_require(...)`.
- Write endpoints use `@frappe.whitelist(methods=["POST"])`.
- User-facing lists use `frappe.get_list` (it applies user permissions), not `frappe.get_all`.
- Writes **allow-list** editable fields. Never `doc.update(client_data)` blindly.
- `allow_guest=True` only for truly public endpoints, with validated input and rate limiting.
- No N+1 queries. Batch lookups with `filters={"name": ["in", names]}`.
- Return shaped dicts with `can_*` flags, e.g. `{"rows": [...], "can_create": True}`.

## 8. No Frappe backend?
Keep the same layers. In `services/`, use `useFetch` from `@vueuse/core` instead of `useCall`
(see the `frappe-ui` skill's SETUP.md). Pages and components stay the same. The rules in §7
apply in that backend's language.

## 9. Step-by-step guides
- New feature: [references/new-feature-checklist.md](references/new-feature-checklist.md)
- New Vue frontend in a Frappe app: [references/scaffold.md](references/scaffold.md)
- Working in a frappe-ui 0.1.x app: [references/legacy-0.1.md](references/legacy-0.1.md)

## 10. Before finishing
- [ ] No endpoint strings or `fetch(` outside `services/`
- [ ] `useCall`/`useList` only called during setup
- [ ] Loading, error and empty states present
- [ ] Every new or changed endpoint checks permission server-side; writes are POST-only
- [ ] No role names, hex colours, raw palette classes or `FeatherIcon` in Vue
- [ ] Page ≤ 400 lines, component ≤ 300 lines
- [ ] `yarn build` (or `npm run build`) passes in the frontend folder
