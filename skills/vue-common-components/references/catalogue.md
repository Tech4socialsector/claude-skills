# Team Component Catalogue (frappe-ui 1.2.0)

These components add to frappe-ui. Build or copy each one to **exactly this contract** (name,
props, events, slots) so pages are portable between projects.
**[template]** = ready code in `../templates/`. **[contract]** = build it to this spec when a
project first needs it, then consider adding it to `templates/`.

Import path: `@/components/common/<Name>.vue`.

---

## DataTable [template]
Table-mode wrapper around `frappe-ui/list` with client-side search and sort, row links, cell
slots, and loading and empty states.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `columns` | Array | **required** | `[{ key, label, width?: '12rem', sortable?: true, align?: 'right', format?: (row) => string }]`. `width` is a CSS grid track; the default is `minmax(0,1fr)` |
| `rows` | Array | `[]` | |
| `loading` | Boolean | `false` | Skeleton rows on first load |
| `rowKey` | String | `'name'` | |
| `rowRoute` | Function | `null` | `(row) => routeLocation`. Rows become links |
| `clickable` | Boolean | `false` | Emits `row-click(row)` (when not using `rowRoute`) |
| `searchable` | Boolean | `true` | |
| `searchPlaceholder` | String | `'Search'` | |
| `emptyTitle` | String | `'No records yet'` | |
| `minWidth` | String | `''` | e.g. `'720px'`. The table scrolls sideways inside its box on small screens |
| `actionsWidth` | String | `'6rem'` | Track for the `#actions` column |

Events: `row-click(row)`.
Slots: `#toolbar` (right of search), `#cell-<key>="{ row, value }"`, `#actions="{ row }"`,
`#empty`.

- **Don't combine `#actions` with `rowRoute` / `clickable`.** The row is already a link or
  button, and nested buttons are invalid. Put row actions on the detail page, or use a
  non-clickable table with `#actions`.
- **Data size:** the table searches and sorts on the client, which is fine up to about 2,000
  rows. Beyond that, use `useList` server paging (`limit`, `next()`, reactive
  `filters`/`orderBy`) with the `List` family directly, or pass `:searchable="false"` and your
  own server-side search.
- Row selection and bulk actions: use the `List` family's `selectable` +
  `v-model:selection` directly (see the `frappe-ui` skill).

```vue
<DataTable :columns="columns" :rows="list.data?.rows || []" :loading="list.loading"
  :row-route="(r) => ({ name: 'ItemDetail', params: { id: r.name } })" min-width="640px">
  <template #toolbar><Button label="Export" icon-left="lucide-download" @click="exportCsv" /></template>
  <template #cell-status="{ value }"><StatusBadge :status="value" /></template>
</DataTable>
```

## StatusBadge [template]
A frappe-ui `Badge` whose colour comes from `src/config/statuses.js`.

| Prop | Type | Default | Notes |
|---|---|---|---|
| `status` | String | `''` | Renders nothing when empty |
| `label` | String | `''` | Display text if different from the stored status |
| `tones` | Object | `null` | Per-use override `{ 'Some Status': 'green' }` |
| `size` | String | `'sm'` | `sm \| md \| lg` |

Tones: `green` done/positive · `red` negative/stopped · `amber` waiting on someone · `blue` in
progress · `violet` special/attention · `gray` neutral (fallback).

## SectionCard [template]
A card surface with an optional header (frappe-ui has no Card).

| Prop | Type | Default |
|---|---|---|
| `title` | String | `''` (no header when empty) |
| `description` | String | `''` |
| `icon` | String | `''` (`lucide-*` class) |

Slots: default (body), `#actions` (header right).

## EmptyState [template]
| Prop | Type | Default |
|---|---|---|
| `title` | String | **required** |
| `description` | String | `''` |
| `icon` | String | `'lucide-inbox'` |

Slot: `#action` (e.g. `<Button variant="solid" theme="gray" label="New …" />`).

---

## ProgressStepper [contract]
Horizontal workflow steps.
`steps: [{ key, label, state: 'completed' | 'current' | 'pending' | 'rejected' | 'skipped' }]`.
Below `sm`, it shows only the current step with an "N of M" label.

## Timeline [contract]
A vertical history or lifecycle (status history, approval log).
`items: [{ key, label, detail?, at?, state?: 'completed' | 'current' | 'pending' | 'rejected', user? }]`,
newest first unless `order="asc"`. Dots use `bg-surface-{green,blue,red,gray}-7` by state, and
`at` is formatted with dayjs.

## DocumentViewer [contract]
| Prop | Notes |
|---|---|
| `open` | `v-model:open` |
| `title` | Default `'Documents'` |
| `documents` | `[{ label, file_url, file_name, kind: 'pdf' \| 'image' \| 'other' }]` |
| `startIndex` | Which document to show first |
| `downloadAllUrl` | Optional ZIP endpoint |

Built on `Dialog size="5xl"`, with prev/next buttons and arrow keys. **Only pass URLs the
backend has permission-checked.** Never make private files public just to preview them.

## SignaturePad [contract]
`v-model` = PNG data URL (`''` when cleared). Props: `label`, `height` (140), `disabled`.
Canvas with pointer events and a "Clear" ghost button. The backend must validate the data URL
(type `image/png`, size limit) before saving.

## EmailAddressInput [contract]
`v-model` = `string[]`. Emails become chips on Enter, comma or paste. It validates the format
and removes duplicates without regard to case. Props: `label`, `placeholder`, `exclude`
(`string[]`).

## BulkResultDialog [contract]
`v-model:open`, `result: { done: string[], failed: [{ name, error }] }`, `title`, and
`labelFor(name)`. Lists failures with their reasons.
**Backend contract:** bulk endpoints return `{ done, failed }` in exactly this shape.

## DrilldownDialog [contract]
`v-model:open`, `title`, `description`, `bucket` and `filters`. Shows a `DataTable` of the
records behind a KPI.
**Backend contract:** the dashboard API exposes `get_drilldown(bucket, filters)`, which returns
`{ columns, rows }` and applies the same permission checks as the KPI itself.
