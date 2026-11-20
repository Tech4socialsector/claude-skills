---
name: vue-common-components
description: Pick the right UI block in Vue + frappe-ui 1.2.0: frappe-ui built-ins first, then team components (DataTable, StatusBadge, SectionCard, EmptyState). Use when building any screen.
---

# Shared UI Building Blocks

**Order of preference:**
1. **A frappe-ui 1.2.0 component** (see the `frappe-ui` skill, CORE.md)
2. **The team's shared component** in `src/components/common/` (this skill)
3. A new feature-local component in `src/components/<feature>/`

Never hand-roll something that exists in levels 1 or 2.

## Step 1: check the project
- Read `package.json`. These rules target **frappe-ui 1.x**. For `0.1.x` see
  `vue-architecture/references/legacy-0.1.md`, and use the project's existing components.
- Look in `src/components/common/` for the team components. If one is missing, copy it from
  [templates/](templates/) or build it to the contract in
  [references/catalogue.md](references/catalogue.md), keeping the **same name and props**.

## Quick pick: "I need…"

| I need… | Use | Source |
|---|---|---|
| Any button | `Button` (`variant` + `theme`, `icon-left="lucide-…"`) | frappe-ui |
| Primary action | `Button variant="solid" theme="gray"`, one per screen | frappe-ui |
| A form field | `FormControl` (`type` = text/select/date/checkbox/…) | frappe-ui |
| Pick one item from a long list or search | `Combobox` (`:filterable="false"` for server search) | frappe-ui |
| Pick several values / multi filter | `MultiSelect` | frappe-ui |
| Pick a person | `Combobox` with `{ label: full_name, value: name }` options | frappe-ui |
| Date / date range | `DatePicker` / `DateRangePicker` | frappe-ui |
| On/off setting | `Switch` | frappe-ui |
| File upload | `FileUploader` (private by default) | frappe-ui |
| Confirm an action | `dialog.confirm({...})` | frappe-ui |
| Confirm a destructive action | `dialog.danger({...})` | frappe-ui |
| Ask for 1–3 values | `dialog.prompt({ fields })` | frappe-ui |
| Custom dialog | `<Dialog v-model:open title>` | frappe-ui |
| Success/info message | `toast.success()`; errors via `notify.error(err)` | frappe-ui + utils/notify |
| Inline notice | `Alert` | frappe-ui |
| Tabs / segmented control | `Tabs` / `TabButtons` | frappe-ui |
| Breadcrumbs / back | `Breadcrumbs` / `PageHeaderBackButton` | frappe-ui |
| App shell, sidebar, header | `DesktopShell`, `Sidebar*`, `PageHeader`; mobile: `MobileShell`, `MobileNav` | frappe-ui |
| Loading placeholder | `Skeleton`, `Spinner`, `LoadingText` | frappe-ui |
| Avatar / progress bar | `Avatar` / `Progress` | frappe-ui |
| KPI tile | `NumberCard` from `frappe-ui/charts` | frappe-ui |
| Chart | `BarChart`, `LineChart`, `DonutChart`, … from `frappe-ui/charts` | frappe-ui |
| Rich text editor | `Editor` from `frappe-ui/editor` | frappe-ui |
| **Table with search + sort + row link** | **`DataTable`** (wraps `frappe-ui/list`) | team · template |
| Feed-style list or custom rows | `List` family directly | frappe-ui |
| **Status pill (colour from config)** | **`StatusBadge`** | team · template |
| **Titled card / section** | **`SectionCard`** (frappe-ui has no Card) | team · template |
| **Nothing here yet** | **`EmptyState`** | team · template |
| Horizontal workflow steps | `ProgressStepper` | team · contract |
| Vertical history / approval log | `Timeline` | team · contract |
| PDF/image preview | `DocumentViewer` | team · contract |
| Signature capture | `SignaturePad` | team · contract |
| Several email addresses | `EmailAddressInput` | team · contract |
| Bulk action result (done/failed) | `BulkResultDialog` | team · contract |
| Click a KPI to see its records | `DrilldownDialog` | team · contract |

Contracts for all team components: [references/catalogue.md](references/catalogue.md).

## Styling rules (1.x)
- Use **semantic tokens only**: `bg-surface-*`, `text-ink-*`, `border-outline-*`, `rounded-1…7`,
  and `text-<size>-<weight>` (e.g. `text-lg-semibold`). Raw palette classes (`bg-gray-100`) and
  named radius (`rounded-lg`) don't work or don't flip in dark mode.
- **Icons:** `<span class="lucide-<name> size-4" aria-hidden="true" />`, or `icon="lucide-<name>"`
  on components.
- **Colour encodes meaning** (status, severity, sign). Everything else is gray. Use at most one
  accent per screen.
- A **brand colour**, if the project needs one, goes in `tailwind.config.js` `theme.extend.colors`
  and is used sparingly (logo, a single accent). Primary buttons stay
  `variant="solid" theme="gray"`, matching frappe-ui.

## Domain-neutral rules
- **Status colours are configuration**: add the project's status words to
  `src/config/statuses.js`. Never special-case a status in a page.
- **No domain words in shared components**: `Timeline`, not `AdmissionTimeline`. Domain
  components live in `components/<feature>/`.
- **All visible text comes in through props or slots**, with neutral defaults.

## Conventions for team components
1. `<script setup>`, props with a type and default, and a shape comment on array/object props.
2. `v-model` for values; `v-model:open` for anything that opens (matches frappe-ui).
3. Emit, don't mutate props.
4. No data fetching unless it's a self-contained widget that takes an ID (then it uses a
   service).
5. Slots for variation (`#actions`, `#toolbar`, `#cell-<key>`, `#empty`).
6. Accessible: labels, `aria-label` on icon-only buttons, keyboard support.
7. Works at 360px, and wide content scrolls inside its own box.
8. ≤ 300 lines.

Adding or changing a team component: [references/adding-a-component.md](references/adding-a-component.md).

## Before finishing
- [ ] Nothing hand-rolled that frappe-ui or a team component already provides
- [ ] `dialog.confirm`/`danger` for confirmations; no custom confirm dialogs
- [ ] Semantic tokens and `lucide-*` icons only
- [ ] New statuses added to `config/statuses.js`
- [ ] Any new team component is documented in the catalogue
