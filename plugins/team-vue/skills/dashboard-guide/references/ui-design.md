# Dashboard UI Design

Visual and interaction rules for every dashboard, whatever the stack. In Vue + frappe-ui, the
class names below are frappe-ui 1.2.0 semantic tokens. In other stacks, use the project's
equivalent tokens.

**Rule zero: match the existing style.** If the project already has dashboards, copy their card,
filter-bar and table layout exactly. Improve usability within that style. Don't redesign unless
asked, and ask when "match vs improve" is unclear.

---

## 1. Layout: four zones, top to bottom

```
┌──────────────────────────────────────────────────────────────┐
│ 1 HEADER   Title · scope sentence · Last updated · Export     │
├──────────────────────────────────────────────────────────────┤
│ 2 FILTERS  [Year ▾] [Programme ▾] [Status ▾]   Apply  Reset   │
│            Active: Year 2026 ×  Programme BA LLB ×            │
├──────────────────────────────────────────────────────────────┤
│ 3 KPIs     ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   (3–6 cards)  │
│            │ 1,240│ │ 92 % │ │  38  │ │  6   │                │
│            └──────┘ └──────┘ └──────┘ └──────┘                │
├──────────────────────────────────────────────────────────────┤
│ 4 DETAIL   ┌── Trend (wide) ───────┐ ┌── Breakdown ──┐        │
│            └───────────────────────┘ └───────────────┘        │
│            ┌── Records needing action (table) ────────┐       │
│            └──────────────────────────────────────────┘       │
└──────────────────────────────────────────────────────────────┘
```

- **Reading order is importance order.** The first KPI (top-left) is the metric the user checks
  first. "Needs action" items go before "nice to know".
- **One question per block.** Every card, chart and table has a title that states the
  question it answers, e.g. "Attendance trend, last 12 weeks", not "Chart 1".
- **Scope sentence** under the title: what data is shown, e.g. "All permitted centres ·
  1 Apr 2026 – today". It updates with the applied filters.
- **Last updated** timestamp in the header for data that isn't live, e.g. "Updated 10:42".
- **Grid:** 12 columns on desktop. KPIs share a row equally. A trend chart is 8/12 with a
  breakdown chart at 4/12, or both 6/12. Tables are full width.
- **Spacing:** `space-y-6` between zones, `gap-4` inside a zone, `p-4` inside cards. Use the
  same values on every dashboard.
- **Width:** `max-w-6xl` (or full width for table-heavy operations dashboards). Gutters
  `px-3 sm:px-5`.
- **Density:** desktop operations users scan, so prefer compact rows (40–44px) and 13–14px
  text over large empty cards.

## 2. KPI cards

Anatomy, top to bottom:

```
┌─────────────────────────────────┐
│ Students present today      ⓘ  │  label: what is counted (sentence case, ≤ 4 words)
│ 1,240                           │  value: largest text on the card, tabular figures
│ ▲ 3.2% vs last week             │  delta: direction + amount + comparison period
│ ▁▂▃▅▆▇ (optional sparkline)     │  trend: only if it adds information
└─────────────────────────────────┘
```

- **3–6 KPIs.** More than 6 means some are filters or table columns in disguise.
- **Every number has context**: a unit (%, ₹, days), a period ("this month"), and ideally a
  comparison (vs previous period, vs target). A bare "1,240" is decoration.
- **Delta colour follows meaning, not sign.** Fewer pending approvals is good (green ▼). Set
  `negativeIsBetter` where it applies. Always show the ▲/▼ arrow, never colour alone.
- **Clickable KPIs** (drilldowns) look clickable: cursor pointer, hover surface
  `hover:bg-surface-gray-2`, a focus ring, and an `aria-label` like "View 38 pending approvals".
- **Filtered vs all-time:** a card that ignores filters says so in its label ("All time") or
  shows an "All time" badge.
- **Attention state:** when a KPI needs action (overdue > 0), tint it with
  `bg-surface-amber-2 border-outline-amber-3` or the red equivalent, and keep a text cue too
  ("6 overdue"). Use this for at most 1–2 cards, otherwise nothing stands out.
- Adjacent cards are separated by borders (`border-outline-gray-1`) and spacing, not by
  different background colours.

## 3. Choosing the chart

| The user's question | Use | Avoid |
|---|---|---|
| How did X change over time? | Line (continuous) / bar (≤ 12 periods) | Pie, area for many series |
| Which category is biggest? | **Horizontal bar, sorted** | Pie with > 5 slices |
| What share of the whole? (≤ 5 parts) | Donut, or 100% bar | 3D pie, > 5 slices |
| How do two series compare over time? | Multi-line (≤ 4 lines) | Stacked area |
| How does a total split by category over time? | Stacked bar | Stacked line |
| Where do things drop off in a process? | Funnel | Donut |
| Is X related to Y? | Scatter | Line |
| Activity by day / calendar intensity | Calendar heatmap | Bar per day |
| One number vs a target | KPI card with progress or delta | Gauge |

Chart rules:
- **Bars start at zero.** Never truncate a bar axis.
- **Sort categorical bars** by value (largest first), unless the order has meaning (months,
  grades, stages).
- **Long labels → horizontal bars.** Never rotate x-axis labels 45°.
- **≤ 6 colours per chart.** Group the rest into "Other".
- **Same category = same colour** on every chart of the dashboard (e.g. "Absent" is always the
  same red).
- **Label units** in the title or axis ("Fees collected (₹ lakh)").
- **Show values directly** (data labels or tooltip) for small series. Gridlines are light
  (`outline-gray-1`) or off.
- **No 3D, no shadows, no gradients, no decorative animation.**
- **Each chart has its own empty state** ("No attendance recorded for this period") instead of
  an empty axis.
- **Height** is fixed per row (e.g. `h-72` for small, `h-80` for wide) so the grid stays
  aligned.

## 4. Colour

- **Gray first.** Text, borders and surfaces are gray tokens (`text-ink-gray-*`,
  `bg-surface-*`, `border-outline-*`). Colour is reserved for meaning.
- **Status colours have fixed meanings** across the whole app: green = good/done,
  amber = needs attention/waiting, red = problem/overdue, blue = in progress/info,
  gray = neutral. Never use red for a neutral category.
- **Categorical palette** (series that are just different groups): use the chart library's
  default palette in order. Don't hand-pick hex values.
- **Never colour alone:** pair colour with an icon, arrow, label or pattern (≈ 8% of men are
  colour-blind; red/green is the common failure).
- **Contrast:** text ≥ 4.5:1 against its background; large numbers and UI shapes ≥ 3:1.
- **Dark mode:** semantic tokens flip automatically. Raw palette classes (`bg-red-100`) and hex
  values don't, so never use them.

## 5. Typography and numbers

- Use frappe-ui type utilities: page title `text-2xl-semibold`, section titles
  `text-lg-semibold`, KPI label `text-sm text-ink-gray-5`, KPI value `text-3xl-semibold` or
  larger, table cells `text-base text-ink-gray-7`.
- **Tabular figures** (`tabular-nums`) for every column of numbers and every KPI, so digits
  line up.
- **Right-align numbers** in tables. Left-align text. Centre nothing except empty states.
- **Format consistently** with `Intl.NumberFormat` in the user's locale:
  - counts: `1,240` (Indian locale `en-IN` gives `12,40,000`)
  - money: `₹ 12.4 L` / `₹ 1.2 Cr` on cards, full value in tables and exports
  - percentages: one decimal (`92.4 %`) on cards; never more than the data supports
  - dates: `12 Nov 2026`; relative ("2 days ago") only for recency, with the full date in a
    tooltip
- Abbreviate large numbers on cards (`12.4 K`). Show the exact value in the tooltip and
  drilldown.
- Show `—` for "no data", not `0`. Zero is a real value.

## 6. States (every block, not just the page)

| State | Show |
|---|---|
| First load | `Skeleton` shapes matching the final layout (card, chart, rows). No layout jump when data arrives |
| Refreshing after Apply | Keep old data visible, dimmed (`opacity-60`), with a small spinner in the header. Don't blank the page |
| Empty | Block-level message saying **why** and **what to do**: "No records for BA LLB in 2026. Try another year." |
| Error | Block-level `ErrorMessage` with **Retry**. Other blocks keep working |
| Partial data | `Alert` theme amber: "Attendance for 3 centres hasn't synced since 10:00" |
| Stale data | "Last updated 3 h ago", in amber when older than the expected refresh interval |
| No permission | "You don't have access to fee data" (server-decided), not an empty chart |

Never show fake or placeholder numbers when a request fails.

## 7. Filter bar design

- **One row** on desktop, wrapping on smaller screens. Filters are left; **Apply** (primary)
  and **Reset** (ghost) are right.
- Order filters from the broadest scope to the narrowest: period → organisation level
  (state → district → block) → category → status.
- **Draft vs applied:** when draft values differ from applied ones, highlight Apply ("Apply 2
  changes") and show "Unapplied changes" text. Keyboard **Enter** applies.
- **Active filter chips** below the bar, each removable (×). "Clear all" resets to defaults.
- **Date range presets** first (Today, This week, This month, This academic year), then
  custom range.
- On mobile, the bar collapses to a "Filters (3)" button that opens a `BottomSheet` / `Dialog`
  with Apply at the bottom.

## 8. Tables on dashboards

- Title states what rows mean and the count: "Pending approvals (38)".
- 5–8 columns. Identifier first, status as a badge, numbers right-aligned, action/date last.
- Default sort answers the question (oldest pending first, highest absence first).
- Row click opens the record or the drilldown. Show the hover surface and keyboard focus.
- Long tables: show the top 10–20 with "View all (238)", which opens the drilldown, rather
  than an endless dashboard.

## 9. Drilldown dialog design

- Centred `Dialog` size `4xl`–`7xl`, max height `85vh`. Only the body scrolls, and the header
  (title, active filters, count, Export) stays fixed.
- The title repeats the metric clicked: "Pending approvals · BA LLB · Nov 2026 (38)".
- Sortable columns, server pagination, Export CSV in the header.
- Closing returns to the exact dashboard state (filters, scroll position).

## 10. Responsive behaviour

| Width | Layout |
|---|---|
| ≥ 1280px (`xl`) | KPIs in one row; charts 8/4 or 6/6 |
| 768–1279px (`md`–`lg`) | KPIs 3 per row; charts stacked or 6/6 |
| < 768px | KPIs 2 per row (1 if values are long); charts full width; tables scroll inside their box or become row cards; filters in a sheet |

Test at 360px, 768px and 1280px, and **resize from desktop to mobile** in the same tab. Nothing
may scroll the whole page sideways.

**Grid pitfall:** every grid cell that holds a chart, table or card needs `min-w-0`, and the grid
needs an explicit `grid-cols-1` base. Without it, a chart drawn at desktop width keeps its cell
wide after the window shrinks (rotated phone, narrowed window), and the page scrolls sideways.

## 11. Accessibility

- Every interactive element is reachable by keyboard, with a visible focus ring (frappe-ui does
  this by default; don't remove `focus-visible` outlines).
- Clickable cards are `<button>` or `<a>`, not `<div @click>`.
- Charts have a text alternative: a one-line summary under the title ("Attendance rose from 86%
  to 92% over 12 weeks") and/or a "View as table" toggle.
- Icons that carry meaning have `aria-label`. Decorative icons have `aria-hidden="true"`.
- Respect `prefers-reduced-motion`. Animations are short (≤ 200 ms) and functional only.

## 12. Performance as design

- The first meaningful content (KPIs) appears in < 2 s. Load KPIs first, then charts and
  tables in parallel, each with its own loading state.
- One request per Apply per block, never one per filter click.
- Aggregate on the server. Never download thousands of rows to count them in the browser.
- Cache filter options (they rarely change) and reuse them across visits.
