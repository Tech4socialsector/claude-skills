# New Feature Checklist

Work in this order. The pattern for each step is in [layers.md](layers.md).

## Understand
1. Read the DocTypes and fields involved, the existing backend module and the existing pages for
   the same area. **Don't invent fields, statuses or endpoints.**
2. List who uses the feature and what each user may read, create, edit and delete.
3. Check the project's frappe-ui version. For `0.1.x`, also follow
   [legacy-0.1.md](legacy-0.1.md).

## Backend
4. Add the endpoint in `<app>/api/<feature>.py`:
   - [ ] Starts with a permission check
   - [ ] Writes are `@frappe.whitelist(methods=["POST"])`
   - [ ] Lists use `frappe.get_list` (permission-aware)
   - [ ] Batch lookups, with no query inside a loop over rows
   - [ ] Writes allow-list editable fields
   - [ ] Returns a shaped dict with the `can_*` flags the UI needs
   - [ ] `allow_guest=True` only if truly public, with validated input
5. Write tests in `<app>/tests/test_<feature>.py`, covering the happy path **and** a
   permission-denied case.

## Frontend
6. **Service** `services/<feature>.js`: `useCall` factories (reads GET; writes POST +
   `immediate: false`).
7. **Composable** `composables/use<Feature>.js`: combine the calls, then reload after writes.
8. **Page** `pages/<Feature>.vue`: compose from the `frappe-ui` skill's components and
   `components/common/` (vue-common-components skill):
   - [ ] Loading (`Skeleton` / `:loading`)
   - [ ] Error (`ErrorMessage` / `notify.error`)
   - [ ] Empty (`EmptyState`)
   - [ ] Destructive actions use `dialog.danger`
9. **Route**: lazy import, `meta`, and `props: true` for detail pages.
10. **Navigation**: add the sidebar item, shown only when `session.can(...)`.
11. **Buttons**: gate them with backend `can_*` flags or `session.can()`, never role names.

## Verify
12. `yarn build` / `npm run build` passes in the frontend folder.
13. `bench --site <site> run-tests --app <app> --module <app>.tests.test_<feature>`
14. Test in the browser as **an allowed user** and **a denied user**. The denied user must get
    a server error, not just a hidden button.
15. Check at phone width (360px) and in dark mode if the app supports it.
16. The browser console is empty (no Vue warnings, no 404s for icons or assets).
