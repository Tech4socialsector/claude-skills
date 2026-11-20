
---
name: dashboard-guide
description: Design, implement, review, and secure rich operational dashboards with KPI cards, dependent filters, tables, drilldowns, CSV exports, consistent visual design, and mandatory security checks. Use whenever building, modifying, debugging, or reviewing dashboards and analytics interfaces.
---

# Dashboard Design Standards

## Purpose

Create professional, useful, secure, responsive dashboards that help users understand operations and take action.

These standards are mandatory whenever designing, implementing, modifying, or reviewing a dashboard. Follow the existing application architecture, preserve business logic, and verify the implementation rather than assuming it is correct.

## 1. Understand users first

- Identify primary users, roles, operational problems, and decisions.
- Every card, chart, table, and filter must serve a clear purpose.
- Start with essential insights and refine based on user feedback.
- Inspect existing code, data sources, field mappings, APIs, and permissions before changing anything.
- Do not invent database fields, metrics, business rules, or API methods.

## 2. Dashboard layout

Combine the following where useful:

- KPI and actionable insight cards.
- Charts for trends, comparisons, and distributions.
- Running tables with meaningful rows and columns.
- All-time metrics where useful.
- Relevant drilldowns and record-level summaries.

Do not create a card-only dashboard when tables and charts would provide better operational insight.

Dashboards must show useful default data on first load. Never require users to select a filter before anything appears unless there is a genuine technical or business reason.

## 3. Filters and filter behaviour

Place filters together near the top of the dashboard. Use clear labels and sensible default values, such as the current month, relevant programme, or all permitted records.

### 3.1 Standard filter features

Provide the following wherever relevant:

- Multi-select.
- Select all.
- Clear selection.
- Search within options.
- Apply/Search button.
- Reset filters button.
- Visible active-filter indicators.
- Sensible default values.
- Clear loading, empty, and error states.
- Permission-aware filter options.

The Apply/Search button must work. It must apply the selected filter values consistently to the relevant cards, charts, tables, and drilldowns.

Reset must restore the intended defaults, not leave the dashboard in an inconsistent state.

### 3.2 Dependent and sequential filters

Filters that have a parent-child relationship MUST use dependent filtering.

Example: State → District → Block.

- When a user selects Jharkhand as the state, the District filter must show only districts belonging to Jharkhand.
- If multiple states are selected, the District filter must show only districts belonging to the selected states.
- The Block filter must show only blocks belonging to the selected districts and permitted states.
- If a parent filter changes, clear or reconcile child selections that are no longer valid.
- Update dependent options from the current parent selection.
- Prevent stale selections from producing misleading results.
- Enforce valid relationships on the server, not just in the interface.
- Respect the user's data permissions when loading filter options.

Users should be able to select a lower-level entity directly when the data model and user experience support it. However, when hierarchical filters are presented, their options and results must remain consistent with the selected parent filters.

Do not show districts from every state after a specific state has been selected.

### 3.3 Apply versus auto-refresh

Use an explicit Apply/Search button as the default for dashboards with multiple filters, especially when filters support multi-select.

Do not refresh the entire dashboard every time a user selects or deselects one item in a multi-select control.

Preferred behaviour:

1. Users change one or more filter values.
2. The selections remain available without triggering repeated dashboard requests.
3. Users click Apply/Search.
4. The dashboard fetches the data once using the combined filter values.
5. Cards, charts, tables, and result counts update consistently.

Auto-refresh may be used for simple filters when it clearly improves usability and does not cause excessive requests, flicker, loss of selections, or confusing intermediate results.

If auto-refresh is used, debounce rapid changes where appropriate and avoid unnecessary API calls.

Keep draft filter selections separate from applied filter state when using an Apply button. Clearly indicate when unapplied changes exist.

### 3.4 Filter consistency

- Related cards, charts, tables, and drilldowns must use the same applied filter state.
- Clearly identify all-time metrics that do not respond to filters.
- Validate dates, IDs, selected options, and filter combinations.
- Never trust client-provided filter values without server-side validation.
- Do not allow filter manipulation to bypass permissions.

## 4. KPI cards and operational insights

Cards must provide meaningful operational insights rather than decorative numbers.

Examples:

- Total centres or creches.
- Average attendance.
- Children enrolled and attending.
- Open positions and candidates in the recruitment pipeline.
- Missing attendance entries.
- Records awaiting action or approval.
- Exceptions requiring operational attention.

For each card, establish:

- Clear title and metric.
- Relevant unit and time period.
- Data source and calculation.
- Filter behaviour.
- User value and intended action.
- Appropriate drilldown, where useful.

Start with a small number of valuable cards and expand based on user feedback.

Avoid duplicating categories already available through filters unless the card adds a distinct and useful insight.

Use clear labels, consistent spacing, and sufficient contrast between adjacent cards. Do not use colour alone to communicate meaning.

## 5. Charts and running tables

Use charts when they make trends, comparisons, distributions, or changes easier to understand.

Include running tables when users need operational details, such as:

- Chronologically ordered candidate applications.
- Operating units and open positions.
- Recruitment pipeline details.
- Attendance records.
- Records requiring action.

Tables should provide:

- Meaningful column headings.
- Readable row spacing.
- Hover highlighting where useful.
- Sorting where appropriate.
- Pagination or incremental loading for large datasets.
- Responsive layouts.
- Clear loading, empty, and error states.

Do not fetch every record into the browser simply to calculate summary counts.

## 6. Drilldowns

Every card, chart, or table row that naturally invites further investigation should have a relevant drilldown.

- Display records that genuinely correspond to the selected metric or row.
- Preserve the relevant applied filters.
- Show a clear title, active filters, and result count.
- Open drilldowns in a centred modal/dialog rather than a small corner pop-out.
- Keep dialogs within the viewport.
- Make dialog content scrollable without causing nested-scroll problems.
- Support ascending and descending sorting where appropriate.
- Use pagination or incremental loading for large result sets.
- Preserve the original dashboard state when a dialog closes.

Where useful, support further drilldowns into individual records.

For recruitment dashboards, a candidate detail view may include relevant application details, interviewer feedback, assessment results, and recruitment history, subject to permissions.

Every drilldown must independently enforce the same access-control rules as the main dashboard.

## 7. CSV exports

Provide CSV exports for drilldown tables wherever appropriate.

- Export the intended result set and respect active filters.
- Export only records the user is authorised to access.
- Enforce permissions again on the server at export time.
- Do not rely on hidden UI elements to protect data.
- Use clear column headings and consistent date and number formats.
- Protect against CSV formula injection.
- Handle large exports safely.
- Validate requested columns and export parameters.

Where an export is intended to represent the visible table, ensure its rows and columns match that table's authorised result set and documented export scope.

Never export restricted records simply because they were hidden in the UI.

## 8. Security — mandatory every time

HTML, JavaScript, and CSS dashboard implementations can introduce security vulnerabilities, especially when they combine client-side rendering, custom APIs, database queries, drilldowns, and exports.

**A security review is mandatory every time a dashboard is created, modified, debugged, or reviewed.** Do not skip security checks because a change appears to be visual or minor.

### 8.1 Client-side security

Inspect HTML and JavaScript for:

- Cross-site scripting (XSS) through untrusted labels, record values, error messages, or HTML rendering.
- Unsafe use of innerHTML, dynamic HTML templates, and DOM insertion.
- Unsafe URL construction, redirects, and user-controlled links.
- Exposed API keys, credentials, secrets, or sensitive data embedded in frontend code.
- Client-side-only permission checks.
- Sensitive information accidentally stored in browser state, URLs, or logs.
- Unsafe use of eval or equivalent dynamic code execution.
- Third-party scripts and dependencies that introduce unnecessary risk.

Prefer safe DOM APIs, text rendering, context-appropriate encoding, validated URLs, and established framework security mechanisms.

CSS is not an access-control mechanism. Hiding a card, column, button, or link with CSS does not protect its data.

### 8.2 Server-side access control

Inspect every data path, including:

- KPI and aggregation endpoints.
- Chart data APIs.
- Table queries.
- Filter-option endpoints.
- Drilldown APIs.
- Individual record details.
- CSV export endpoints.
- Custom reports and background operations.

For each path:

- Enforce authentication and authorisation on the server.
- Respect roles, record-level permissions, user restrictions, and field-level access requirements.
- Validate record IDs, filters, sorting fields, pagination, and requested columns.
- Use parameterised queries or safe query builders.
- Allowlist permitted sorting fields and other dynamic query components.
- Avoid exposing restricted records through counts, aggregates, or filter options.
- Return only the minimum data necessary for the operation.

For Frappe/ERPNext, inspect DocType permissions, roles, User Permissions, applicable document-level rules, and custom API implementations. Custom SQL and custom API methods must not be assumed to enforce Frappe permissions automatically.

Never rely exclusively on client-side filtering to enforce access control.

### 8.3 Export and drilldown security

Verify that:

- Direct API calls cannot retrieve restricted records.
- Changing a record ID does not expose another user's data.
- Altering filter parameters cannot bypass record restrictions.
- Export requests apply the same authorisation rules as the dashboard.
- Drilldown data and record details remain permission-safe.
- CSV values are protected against formula injection.
- Error responses do not disclose sensitive implementation details.

### 8.4 Security validation

Test relevant scenarios using different permission levels and, where safe and authorised, direct API requests.

Include:

- Authorised users can access permitted records.
- Unauthorised users cannot access restricted records.
- Manipulated filters and record IDs do not bypass access control.
- Exports cannot include restricted data.
- Untrusted values cannot execute script in the interface.
- Missing or invalid inputs fail safely.

Do not claim security has been verified unless the relevant code was inspected and the available tests were actually performed.

Report security findings by severity, explain their impact, and recommend fixes. Do not silently ignore unresolved high-risk findings.

## 9. Visual design and accessibility

- Use consistent typography, spacing, borders, and component styles.
- Keep labels clear and the information hierarchy obvious.
- Use colour purposefully with sufficient contrast.
- Distinguish adjacent cards clearly.
- Support desktop, tablet, and mobile layouts.
- Provide accessible labels, keyboard navigation, and visible focus states.
- Include loading, empty, partial-data, and error states.
- Avoid clutter, unnecessary decoration, and excessive animation.

Visual polish must not come at the cost of usability, performance, or security.

## 10. Performance and reliability

- Use efficient, permission-aware aggregation queries.
- Avoid unnecessary requests and duplicate submissions.
- Avoid refreshing after every multi-select change when an Apply button is more appropriate.
- Prevent stale responses from overwriting newer filter results.
- Use pagination for large datasets.
- Handle failed requests and partial data explicitly.
- Never silently replace failed live data with fake values.
- Keep card, chart, table, and drilldown calculations consistent.
- Preserve selections and applied filters appropriately during loading and refresh.

## 11. Reference examples

When accessible, use these as interaction and design references:

- Running journal: http://13.126.167.96/run-journal
- Run-detail.js page, including its map and supporting statistics.
- Network hospital dashboard.

Learn from useful interaction patterns without copying blindly.

Do not claim to have inspected a reference that you could not access.

## 12. Implementation workflow

Follow this workflow whenever implementing or substantially changing a dashboard:

1. Inspect the existing HTML, CSS, JavaScript, data sources, APIs, field mappings, and permissions.
2. Identify users, operational needs, and intended insights.
3. Map each metric to its source fields, calculation, scope, and access rules.
4. Design cards, charts, tables, defaults, and drilldowns.
5. Design dependent filters and define which changes require Apply/Search.
6. Implement consistent applied-filter state across all related components.
7. Implement relevant centred drilldowns, sorting, scrolling, and secure exports.
8. Enforce server-side permissions for all data-access paths.
9. Perform a mandatory security review of the frontend, backend, APIs, drilldowns, and exports.
10. Test filter dependencies, defaults, calculations, refresh behaviour, sorting, exports, and responsiveness.
11. Review the implementation against `references/dashboard-review-checklist.md`.
12. Report changes, assumptions, test results, security findings, and deployment steps.

Do not replace existing code without understanding its dependencies and behaviour. Do not claim tests passed unless they were run.

## 13. Expected deliverables

When relevant, provide:

- Proposed dashboard layout and filter behaviour.
- Metric-to-field mappings.
- Complete code when requested.
- Exact file locations and configuration steps.
- Security findings and permission considerations.
- Validation results separating completed tests from pending tests.
- Known limitations and unresolved risks.

Follow the user's requested output format. Preserve existing functionality unless a change is explicitly requested.
