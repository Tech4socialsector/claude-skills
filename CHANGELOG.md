# Release Notes

All notable changes to the team Claude Code skills. Newest first.
Version numbers follow [Semantic Versioning](https://semver.org); the current version lives in
`.claude-plugin/plugin.json`.

**To get the latest version:** `bash ~/claude-skills/install.sh`
(first install: see the [README](README.md#install-for-teammates)).

---

## v1.4.1 (2026-11-26)

### Features
- **Upstream skills install as whole folders.** Skills from other repos now install with
  everything they need (`SKILL.md` plus `references/`, `scripts/`, …), not just `SKILL.md`.
  Multi-file skills from `frappe/skills`, such as `review-ui-states` (19 files) or `ship-it`
  (11 files), can now be added with one line.
- New `skills/README.md` lists every skill and where it comes from, so `frappe-app-dev` is
  visible on GitHub even though it's downloaded at install time.

### Bug Fixes
- Upstream skills with more than one file would have installed incomplete. Fixed by
  downloading the pinned folder instead of a single file.

### Implementation
- `upstream-skills.txt` has a clearer format:
  `<name> | <owner>/<repo> | <full commit SHA> | <folder path>`.
- The installer downloads one GitHub archive per repo and commit, and reuses it for every skill
  from that repo.

### Security
- Upstream entries are validated: full 40-character commit SHA only, safe skill and repo
  names, no `..` in paths. Malformed lines are skipped with a warning.
- An upstream skill can't overwrite a team skill with the same name.

### Upgrade notes
- Run `bash ~/claude-skills/install.sh`. Nothing else to do.

---

## v1.4.0 (2026-11-26)

### Features
- **One-line install**, now that the repo is public:
  `curl -fsSL https://raw.githubusercontent.com/Tech4socialsector/claude-skills/main/install.sh | bash`
  It clones into `~/claude-skills` the first time and updates it on later runs.
- `TARGET=…` installs into a single project's `.claude/skills` (for example for Claude Code
  on the web).

### Bug Fixes
- Downloads now time out (10 s to connect, 60–120 s total), so a stalled network can't hang the
  installer.

### Implementation
- **Flat repo layout:** skills moved from `plugins/team-vue/skills/` to `skills/`. Plugin
  manifests moved to the root `.claude-plugin/`, and the marketplace source is now `./`.
- Upstream skills moved out of `install.sh` into `upstream-skills.txt`.
- The version number lives only in `.claude-plugin/plugin.json`; `author` added.
- `claude plugin validate .` passes.

### Upgrade notes
- Teammates on the old layout: run `bash ~/claude-skills/install.sh` as usual. It pulls the
  new layout and restarts itself automatically (tested).

---

## v1.3.2 (2026-11-26)

### Bug Fixes
- After `git pull` replaced `install.sh`, bash kept running the **old** script, which could
  remove `frappe-app-dev`. The installer now restarts itself with the updated script after a
  pull.

### Upgrade notes
- Upgrading from v1.3.0 or older: run the installer twice the first time.

---

## v1.3.1 (2026-11-26)

### Features
- The repo is **public**: no GitHub account, login or invite needed to install.

### Implementation
- `frappe-app-dev` is downloaded at install time from `frappe/skills` (pinned to `d213dce`)
  instead of being copied into this repo, because that repo has no license.
- A failed download keeps the previously installed copy and never removes it.

### Documentation
- README: removed the GitHub login and access steps; added the "Upstream skills" section.

---

## v1.3.0 (2026-11-26)

### Features
- **New skill: `frappe-app-dev`**, Frappe's official skill for working in Frappe apps (code,
  migrate, tests, test sites with the Pilot CLI). On plain `bench`, read `pilot frappe` as
  `bench`.

---

## v1.2.0 (2026-11-26)

### Features
- **`dashboard-guide` rewritten** with a full UI-design guide
  (`references/ui-design.md`):
  - four-zone layout and KPI card anatomy
  - a chart-selection table
  - colour, number formatting and per-block states (loading, empty, error, partial)
  - filter bar, drilldown and responsive rules, accessibility
- **Dashboard templates** (Vue + frappe-ui 1.2.0 + Frappe):
  - `DashboardPage.vue`: a complete example page
  - `useDashboardFilters.js`: draft vs applied filters, dependent filters, chips
  - `dashboard.service.js`: frontend calls to the backend
  - `dashboard_api.py`: permission-aware KPIs, server-paged drilldowns, CSV export that
    blocks formula injection
- Expanded review checklist: UI design, responsive, accessibility and hand-over report.

### Bug Fixes
- `dashboard-guide` had a blank line before its frontmatter, so Claude couldn't read its name
  or description. Fixed.
- **Mobile overflow:** chart grid cells now use `min-w-0`, so the page no longer scrolls
  sideways after resizing from desktop to phone width.
- **`yarn dev` crash with frappe-ui 1.2.0** (`Could not resolve "#utils/debounce"` from
  `frappe-ui/charts`): documented the `optimizeDeps.exclude` fix in the `vue-architecture`
  scaffold guide.
- The backend template works on both **Frappe v15 and v16**. v16 needs dict syntax for
  aggregate fields; v15 needs the string form.

### Tested
- Filter logic: 8 of 8 unit tests pass.
- Browser: 13 of 13 checks pass with no console warnings (render, a single request per Apply,
  KPI drilldown, paging, Reset, 360 px layout).
- Query shapes checked read-only on Frappe v16.7.

---

## v1.1.0 (2026-11-20)

### Features
- **New skill: `dashboard-guide`**, the team's dashboard standards: filters, KPIs, tables,
  drilldowns, CSV export and a mandatory security review.
- **`install.sh`** installs or updates every skill into `~/.claude/skills` with one command:
  - pulls the latest version fast-forward only, and never overwrites local changes or commits
  - removes team skills that were deleted from the repo
  - never touches personal skills

### Implementation
- Skill descriptions shortened to 200 characters or fewer, so they can also be uploaded to
  claude.ai.
- The version is set in one place (`plugin.json`).

### Documentation
- README: installation guide, maintenance guide, troubleshooting, pinned stack.

---

## v1.0.0 (2026-11-20)

### Features
- **`vue-architecture`**, the team standard for Vue 3 + frappe-ui 1.2.0 frontends:
  - folder layout, and the page → composable → service → backend data flow
    (`useCall` / `useList`)
  - access checks by capability, not role names
  - backend rules: permission checks, POST-only writes, `get_list`, no N+1 queries
  - size limits, plus a scaffold guide for new Frappe-app frontends
- **`vue-common-components`**: a "which component to use" guide, frappe-ui built-ins first.
  Templates: `DataTable` (on `frappe-ui/list`), `StatusBadge` + `statuses.js`, `SectionCard`,
  `EmptyState`.
- **`frappe-ui`**: the official frappe-ui v1.2.0 skill, unchanged (MIT).
- Templates `api.js` and `notify.js`, compatible with frappe-ui 0.1.x and 1.x.
- `legacy-0.1.md` for apps still on frappe-ui 0.1.x.
- Optional Claude Code plugin install (`team-vue@team-skills`).

### Tested
- All templates built and rendered on frappe-ui 1.2.0 + Vite 7 with no console errors or Vue
  warnings.

### Pinned stack
frappe-ui **1.2.0** · Vue ^3.5 · vue-router ^4.5 · Pinia ^3.0 · Vite ^7.3 ·
@vitejs/plugin-vue ^6.0 · Tailwind ^3.4 (not v4) · Node ≥ 20.19 · Frappe v15+
