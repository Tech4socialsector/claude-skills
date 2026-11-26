# Dashboard Review Checklist

Use before handing over or approving any dashboard. Report each unchecked item as done, not
applicable, or pending (with the reason).

## User value
- [ ] Users, roles and the decisions supported are identified
- [ ] Every card, chart and table answers a stated question or supports an action
- [ ] Useful on first load with sensible defaults; no blank "select filters first" screen
- [ ] Metric definitions written down (source fields, calculation, period, scope)
- [ ] No redundant cards that just repeat a filter's categories

## UI design ([ui-design.md](ui-design.md))
- [ ] Matches the project's existing dashboard style (or a redesign was requested)
- [ ] Four zones in order: header → filters → KPIs → detail
- [ ] Header has the title, a scope sentence reflecting the applied filters, and "Last updated"
- [ ] 3–6 KPIs, each with unit, period and comparison; delta colour follows meaning
- [ ] Chart type fits the question; bars start at zero; categorical bars sorted; ≤ 6 colours
- [ ] Same category has the same colour on every chart; units are labelled
- [ ] Gray base, colour only for meaning, never colour alone; no raw palette or hex colours
- [ ] Numbers: tabular figures, right-aligned in tables, locale-formatted, `—` for no data
- [ ] Spacing and sizes consistent with the other dashboards
- [ ] Every block has loading, refreshing, empty (with reason), error (with retry) and
      partial-data states

## Filters
- [ ] Ordered from broadest to narrowest; sensible defaults
- [ ] Multi-select, select all, clear and search within options where relevant
- [ ] Draft vs applied: changing a control doesn't fetch; Apply fetches once; unapplied
      changes visible
- [ ] Reset restores defaults; active filters shown as removable chips
- [ ] Dependent filters: child options follow parents; invalid child selections removed;
      server validates too
- [ ] Filter options are permission-safe
- [ ] Metrics that ignore filters are marked "All time"

## Drilldowns and exports
- [ ] Each drilldown matches the clicked KPI, bar or row, and uses the same applied filters
- [ ] Centred dialog; header fixed, only the body scrolls; stays within the viewport
- [ ] Title repeats the metric; shows active filters and the result count
- [ ] Sortable (asc/desc) with server pagination for large sets
- [ ] Closing restores the exact dashboard state
- [ ] CSV export where useful; scope matches the authorised result set
- [ ] Export re-checks permission on the server; formula injection is blocked

## Security (mandatory)
- [ ] Server checks permission for KPIs, charts, tables, filter options, drilldowns, record
      details and exports
- [ ] User-facing reads use permission-aware queries (`frappe.get_list` or explicit conditions)
- [ ] Filters, IDs, dates, page sizes validated; sort fields and bucket names allowlisted;
      no string-built SQL
- [ ] No restricted data shipped to the browser and merely hidden
- [ ] No `v-html` / `innerHTML` with data; no secrets in frontend code, URLs or storage
- [ ] Tested as a full-access user **and** a restricted user, including manipulated API calls
- [ ] Error messages don't reveal internals

## Responsive and accessible
- [ ] Works at 360px, 768px and 1280px, and after resizing desktop → mobile (no sideways page
      scroll; chart grid cells have `min-w-0`)
- [ ] Filters usable on mobile (wrap or sheet)
- [ ] Clickable cards and rows are buttons or links, keyboard-reachable, with visible focus
- [ ] Text contrast ≥ 4.5:1; charts have a text summary or table alternative
- [ ] Works in dark mode if the app supports it

## Performance and reliability
- [ ] KPIs appear first; blocks load in parallel with their own states
- [ ] One request per Apply per block; stale responses can't overwrite newer ones
- [ ] Aggregation on the server; large sets paginated; filter options cached
- [ ] Partial failures handled per block; no fake numbers on failure
- [ ] Card, chart, table and drilldown numbers come from the same server filter logic

## Hand-over report
- [ ] Changes, files and deployment steps listed
- [ ] Metric definitions included
- [ ] Tests run vs tests pending stated honestly
- [ ] Security findings listed by severity, with open risks called out
