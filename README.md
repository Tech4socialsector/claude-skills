# Team Skills for Claude Code

Shared [Claude Code](https://code.claude.com) skills for the Tech4socialsector team. They teach
Claude how **we** build Frappe apps, Vue 3 + frappe-ui frontends and dashboards, so every project
and every teammate gets the same structure, components and security checks, whatever the domain.

Repo: <https://github.com/Tech4socialsector/claude-skills> (public)

| Skill | Claude uses it when you… |
|---|---|
| `vue-architecture` | add or change pages, routes, composables, services, stores or API calls, or scaffold a new Vue frontend |
| `vue-common-components` | build any screen: tables, status badges, cards, dialogs, filters, pickers, empty states |
| `dashboard-guide` | build, change or review a dashboard (UI design, KPIs, charts, filters, drilldowns, exports, security), with ready Vue + backend templates |
| `frappe-ui` | write frappe-ui markup (official reference for v1.2.0: exact props, slots, tokens, data composables) |
| `frappe-app-dev` | work in any Frappe app (hooks.py + DocTypes): write or review backend code, run migrate or tests, set up a test site for a PR (official Frappe skill, downloaded by the installer; see [Upstream skills](#upstream-skills)) |

---

## Install (for teammates)

Works for Claude Code in **VS Code** and in the **terminal**, on Linux, macOS and Windows
(Git Bash / WSL). Needs `git` and `curl`. **No GitHub account or login is needed.**

### 1. Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/Tech4socialsector/claude-skills/main/install.sh | bash
```

This clones the repo into `~/claude-skills` and installs the skills into `~/.claude/skills`.
Expected output:

```
Cloning https://github.com/Tech4socialsector/claude-skills.git into /home/<you>/claude-skills ...
  installed  dashboard-guide
  installed  frappe-ui
  installed  vue-architecture
  installed  vue-common-components
  installed  frappe-app-dev (upstream frappe/skills@d213dce)
Done: team skills v1.4.1 installed in /home/<you>/.claude/skills
```

> Prefer to look first? `git clone https://github.com/Tech4socialsector/claude-skills.git ~/claude-skills`,
> read `install.sh`, then run `bash ~/claude-skills/install.sh`. Same result.

### 2. Check they're loaded
1. VS Code: **Ctrl+Shift+P → Developer: Reload Window**. Terminal: start a new `claude`
   session.
2. In the Claude Code chat, type `/`. You should see `vue-architecture`,
   `vue-common-components`, `dashboard-guide`, `frappe-ui` and `frappe-app-dev`.
3. Try it: *"Add a list page for <DocType> with search and a status column"*. Claude should
   follow the service → composable → page structure and use `DataTable` + `StatusBadge`.

The skills are now active in **every project** you open.

### Update

Run the same one-liner again, or:

```bash
bash ~/claude-skills/install.sh
```

It pulls the latest version, replaces only the team skills, re-downloads the upstream skills,
removes team skills that were deleted from the repo, and never touches your personal skills.

### Install for one project only (optional)

```bash
TARGET=/path/to/project/.claude/skills bash ~/claude-skills/install.sh
```

Commit that `.claude/skills` folder if the project is also used with **Claude Code on the web**
(claude.ai/code), because cloud sessions only see skills committed inside the repo.

### Troubleshooting

| Problem | Fix |
|---|---|
| `could not reach GitHub` / `could not download frappe-app-dev` | Check your network (and proxy), then run the installer again. Already-installed skills are kept |
| `has local changes, so it was NOT updated` | You edited files in `~/claude-skills`. Discard them with `git -C ~/claude-skills reset --hard origin/main`, then rerun |
| Skills don't appear after `/` | Reload VS Code / start a new session; check `ls ~/.claude/skills` |
| Two copies of a skill (e.g. `vue-architecture` and `team-vue:vue-architecture`) | You installed both ways. Keep one: remove the plugin (`/plugin`) **or** the folder in `~/.claude/skills` |
| You had a personal skill with the same name | The installer replaced it. Rename your personal skill if you need both |
| Upgrading from v1.3.x or older | Just run `bash ~/claude-skills/install.sh`; it moves you to the new layout automatically |

---

## Repository layout

```
claude-skills/
├── README.md                  this guide
├── install.sh                 installer / updater (run it; never edit ~/.claude/skills by hand)
├── upstream-skills.txt        skills installed from other repos (e.g. frappe-app-dev), pinned
├── .claude-plugin/            optional plugin install route (see "Other ways to install")
│   ├── plugin.json            plugin "team-vue" + THE version number
│   └── marketplace.json       marketplace "team-skills"
└── skills/                    ← every team skill lives here, one folder each
    ├── dashboard-guide/       SKILL.md, references/, templates/
    ├── frappe-ui/             official frappe-ui skill v1.2.0 (MIT, unchanged)
    ├── vue-architecture/      SKILL.md, references/, templates/
    └── vue-common-components/ SKILL.md, references/, templates/
```

Each skill folder follows the same pattern:

| Path | Holds |
|---|---|
| `SKILL.md` | The rules Claude reads first (short, ≤ ~200 lines) |
| `references/*.md` | Longer guides Claude opens when needed |
| `templates/*` | Ready-to-copy code (tested on the pinned stack) |

---

## Maintain (for skill maintainers)

### Change or add a skill

```bash
cd ~/Documents/Skills          # or wherever you keep your clone with push access
git pull
# edit skills/<skill>/...   — or add skills/<new-skill>/SKILL.md
```

1. **Test locally** before pushing:
   ```bash
   SKIP_PULL=1 bash install.sh       # installs your working copy into ~/.claude/skills
   ```
   Reload VS Code and try a request that should use the skill.
2. **Bump the version** in `.claude-plugin/plugin.json` (e.g. `1.4.0 → 1.5.0`). It's the only
   place the version lives.
3. **Commit and push** (Conventional Commits):
   ```bash
   git add .
   git commit -m "feat(vue-architecture): add pagination rule (v1.5.0)"
   git push
   ```
4. **Tell the team** to run `bash ~/claude-skills/install.sh`.

### Rules for skill files
- Every skill is a folder in `skills/` with a `SKILL.md` that starts on line 1 with:
  ```yaml
  ---
  name: my-skill              # same as the folder name, lowercase-with-dashes
  description: What it does and when to use it.   # ≤ 200 characters (claude.ai limit)
  ---
  ```
  Nothing may come before the first `---`, not even a blank line, or Claude can't read the skill.
- Keep `SKILL.md` short. Put details in `references/*.md` and code in `templates/`.
- No secrets, credentials, personal data or internal URLs. **This repo is public.**
- **Don't edit `skills/frappe-ui/`.** It's the official upstream reference. To upgrade it, follow
  `skills/frappe-ui/VERSION.md`, update the pinned version in `vue-architecture`, rebuild the
  templates on the new version, and bump the plugin version.
- **Don't copy other people's skills into `skills/`** unless their license allows it. List
  them in `upstream-skills.txt` instead (see [Upstream skills](#upstream-skills)).

### Validate before pushing (optional)

```bash
claude plugin validate .
```

"Validation passed" is what matters. Notes about a missing LICENSE or icon only apply to
submitting to Anthropic's public plugin directory.

### Pinned stack (what the skills assume)

| Package | Version |
|---|---|
| frappe-ui | **1.2.0** (exact pin) |
| vue / vue-router / pinia | ^3.5 / ^4.5 / ^3.0 |
| vite / @vitejs/plugin-vue | ^7.3 / ^6.0 |
| tailwindcss | ^3.4 (not v4) |
| Node | ≥ 20.19 |
| Frappe | v15+ |

Older apps on frappe-ui `0.1.x` are covered by `vue-architecture/references/legacy-0.1.md`.

---

## Upstream skills

Skills from other teams' repos are **not copied** into this public repo (their repos have no
license). Instead `upstream-skills.txt` lists them, and `install.sh` downloads the **whole skill
folder** (SKILL.md plus any references/ or scripts/) at an exact, pinned commit.

| Skill | Source | Pinned commit |
|---|---|---|
| `frappe-app-dev` | [frappe/skills](https://github.com/frappe/skills/tree/main/skills/frappe-app-dev) | `d213dce` (2026-11-13) |

`frappe-app-dev` is written for Frappe's **Pilot** CLI (`pilot frappe --site SITE …`). On a plain
`bench` setup, read `pilot frappe` as `bench` and `pilot start` as `bench start`; its Code and
Tests sections apply as-is.

`upstream-skills.txt` format, one skill per line:

```
<skill-name> | <owner>/<repo> | <full 40-char commit SHA> | <folder path in that repo>
frappe-app-dev | frappe/skills | d213dce39942c969293e9fe7feb96ab33cbba25c | skills/frappe-app-dev
```

- **Add one:** add a line (get the SHA from the repo's latest commit on GitHub), run
  `SKIP_PULL=1 bash install.sh` to test, update the table above, bump the version, push.
  `frappe/skills` also has e.g. `frappe-code-review`, `code-style`, `ui-design`,
  `review-ui-states`, `technical-writing`; multi-file skills work too.
- **Update one:** review the upstream changes, replace the SHA, test, update the table, bump the
  version, push.
- The installer refuses a name that clashes with a team skill in `skills/`, skips malformed
  lines, and keeps the previously installed copy if a download fails.

---

## Other ways to install

Use **one** method per machine, or Claude sees two copies of each skill.

**Claude Code plugin** (skills appear as `team-vue:<skill>`):

```
/plugin marketplace add Tech4socialsector/claude-skills
/plugin install team-vue@team-skills          → choose "User" scope
```

Update with `/plugin marketplace update team-skills`, then `/plugin` → Installed → Update now.
The plugin doesn't include the upstream skills. Install `frappe-app-dev` separately:

```bash
mkdir -p ~/.claude/skills/frappe-app-dev
curl -fsSL https://raw.githubusercontent.com/frappe/skills/d213dce39942c969293e9fe7feb96ab33cbba25c/skills/frappe-app-dev/SKILL.md \
  -o ~/.claude/skills/frappe-app-dev/SKILL.md
```

**Claude.ai web chat:** turn on code execution in Settings → Capabilities, then zip each skill
folder and upload it under Customize → Skills → **+** → Create skill → Upload a skill:

```bash
cd ~/claude-skills/skills
zip -r ~/vue-architecture.zip vue-architecture
zip -r ~/vue-common-components.zip vue-common-components
zip -r ~/dashboard-guide.zip dashboard-guide
```

Don't upload `frappe-ui` or `frappe-app-dev` to claude.ai, because their descriptions are over
claude.ai's 200-character limit. On a Team or Enterprise plan, an owner can provision the skills
for everyone (Organization settings → Plugins & skills).
