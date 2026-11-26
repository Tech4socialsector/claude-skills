# Working in a frappe-ui 0.1.x Project

Older apps still run frappe-ui `0.1.x`. **The team standard is 1.2.0**, but don't upgrade
inside a feature task. Upgrading is a separate, planned job (frappe-ui ships a migration guide
and a token codemod, `tokens-v2`).

In a 0.1.x project, the **structure rules still apply** (layers, permissions, size limits,
states). Only the frappe-ui API calls differ:

| Topic | 1.2.0 (standard) | 0.1.x (legacy) |
|---|---|---|
| Data, reads | `useCall({ url: method(...) })`, `useList`, `useDoc` | `createResource({ url: 'app.api.x', auto: true })`, `createListResource`, or `call()` in a service |
| Data, writes | `useCall({ method: 'POST', immediate: false })` + `submit()` | `call('app.api.x', params)` or `resource.submit()` |
| Bootstrap | `FrappeUIProvider` in App.vue; `app.use(FrappeUI)` optional | `app.use(FrappeUI)` + `setConfig('resourceFetcher', frappeRequest)` in main.js |
| Icons | `lucide-*` classes, `icon="lucide-x"` | `<FeatherIcon name="x" />`, `icon="x"` |
| Badge colours | `gray blue green amber red violet` | `gray blue green orange red` |
| Dialog | `<Dialog v-model:open title="...">` default slot, `#actions` | `<Dialog v-model :options="{ title, size }">` with `#body-content`, `#actions` |
| Confirm | `dialog.confirm` / `dialog.danger` | the project's own confirm dialog component |
| Lists | `List` family from `frappe-ui/list` | `ListView` or the project's own table |
| Charts | `frappe-ui/charts` (`NumberCard`, `BarChart`, …) | the project's own ECharts wrapper |
| Toasts | `toast.success/error/warning/info` | the same in recent 0.1.x. Check that `toast.success` exists in `node_modules/frappe-ui/src/index.*` |
| Tokens | `bg-surface-*`, `text-ink-*`, `rounded-4…7` | the older token set (`rounded-lg`, `text-gray-*`). Match the surrounding code |
| Tailwind preset | `import preset, { content } from 'frappe-ui/tailwind'` | `import preset from 'frappe-ui/tailwind'` + manual content globs |

**Rule of thumb:** in a legacy project, open two existing pages and copy their frappe-ui usage
exactly. Use the `frappe-ui` skill only for general guidance, because its props describe 1.x.

The team templates in `vue-common-components/templates/` target 1.2.0. In a 0.1.x project, use
the project's existing shared components instead, or adapt the template (icons → `FeatherIcon`,
`amber` → `orange`, tokens → the project's classes).
