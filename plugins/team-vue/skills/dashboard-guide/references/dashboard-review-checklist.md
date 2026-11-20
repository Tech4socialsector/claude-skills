# Dashboard Review Checklist
 
Use this checklist before handing over a dashboard.
 
## User value
- [ ] Primary users and operational decisions are identified.
- [ ] Every card/visual answers a useful question or supports an action.
- [ ] Dashboard is useful on first load; no blank-screen gate.
- [ ] Cards and running tables are both considered.
- [ ] Redundant cards are avoided when a filter already handles the category.
## Filters
- [ ] Sensible defaults are applied.
- [ ] Multi-select, select all, clear, and search are supported where relevant.
- [ ] Users can select lower-level entities directly where appropriate.
- [ ] Apply/Search works, or clearly explained auto-apply works.
- [ ] Reset is available.
- [ ] Active filters are visible.
- [ ] Filter options are permission-safe.
## Cards and tables
- [ ] Titles, values, units, time ranges, and scope are clear.
- [ ] Filtered versus all-time metrics are distinguishable.
- [ ] Related components use consistent filter state.
- [ ] Adjacent cards have sufficient contrast.
- [ ] Tables have useful columns, loading/empty/error states, and responsive behaviour.
## Drilldowns and exports
- [ ] Drilldown is relevant to the clicked card/chart/row.
- [ ] Drilldown opens centred and does not disrupt the dashboard state.
- [ ] Modal/dialog height and scrolling work.
- [ ] Sortable headers support ascending and descending order.
- [ ] Large result sets are paginated or incrementally loaded.
- [ ] CSV export is available where appropriate.
- [ ] Export scope matches the visible, authorised result set.
- [ ] Further record details are useful and permission-safe.
## Security 
- [ ] Server checks permissions for cards, charts, tables, filter options, drilldowns, record details, and exports.
- [ ] No restricted data is shipped to the browser and merely hidden.
- [ ] User-supplied filters, IDs, sort fields, and pagination are validated.
- [ ] SQL/query construction uses safe parameters and allowlists.
- [ ] Different roles and limited-access users have been tested.
- [ ] Error messages do not reveal sensitive data.
## Quality
- [ ] Responsive layout works on desktop, tablet, and mobile.
- [ ] Keyboard navigation, focus states, and contrast are adequate.
- [ ] Loading, empty, partial-data, and error states are handled.
- [ ] API calls and aggregation are efficient.
- [ ] Filter changes cannot be overwritten by stale responses.
- [ ] Tests performed and tests still needed are reported honestly.