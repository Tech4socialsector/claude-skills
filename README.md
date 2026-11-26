# Team Skills for Claude Code

Shared [Claude Code](https://code.claude.com) skills for the Tech4socialsector team. They teach
Claude how **we** build Vue 3 + frappe-ui frontends and dashboards, so every project and every
teammate gets the same structure, components and security checks, whatever the domain.

Repo: <https://github.com/Tech4socialsector/claude-skills>

| Skill | Claude uses it when you… |
|---|---|
| `vue-architecture` | add or change pages, routes, composables, services, stores or API calls, or scaffold a new Vue frontend |
| `vue-common-components` | build any screen: tables, status badges, cards, dialogs, filters, pickers, empty states |
| `dashboard-guide` | build, change or review a dashboard (UI design, KPIs, charts, filters, drilldowns, exports, security), with ready Vue + backend templates |
| `frappe-ui` | write frappe-ui markup (official reference for v1.2.0: exact props, slots, tokens, data composables) |

---

## Installation guide (for teammates)

Works for Claude Code in **VS Code** and in the **terminal**. You only do steps 1–3 once.

### 1. Prerequisites
- Read access to the GitHub repo (ask the repo admin to add you).
- `git` logged into GitHub. With the GitHub CLI:
  ```bash
  gh auth login        # choose GitHub.com → HTTPS → log in with browser
  gh auth setup-git
  ```
- Windows: run the commands in **Git Bash** or **WSL**.

### 2. Clone the repo

```bash
git clone https://github.com/Tech4socialsector/claude-skills.git ~/claude-skills
```

### 3. Install the skills

```bash
bash ~/claude-skills/install.sh
```

Expected output:

```
Updating /home/<you>/claude-skills from GitHub ...
  installed  dashboard-guide
  installed  frappe-ui
  installed  vue-architecture
  installed  vue-common-components
Done: team skills v1.2.0 installed in /home/<you>/.claude/skills
```

### 4. Check they're loaded
1. VS Code: **Ctrl+Shift+P → Developer: Reload Window**. Terminal: start a new `claude`
   session.
2. In the Claude Code chat, type `/`. You should see `vue-architecture`,
   `vue-common-components`, `dashboard-guide` and `frappe-ui`.
3. Try it: *"Add a list page for <DocType> with search and a status column"*. Claude should
   follow the service → composable → page structure and use `DataTable` + `StatusBadge`.

The skills are now active in **every project** you open.

### Updating
When the team announces a new version, run the same command again:

```bash
bash ~/claude-skills/install.sh
```

It pulls the latest version, replaces only the team skills, removes team skills that were
deleted from the repo, and never touches your personal skills.

### Install for one project only (optional)

```bash
TARGET=/path/to/project/.claude/skills bash ~/claude-skills/install.sh
```

Commit that `.claude/skills` folder if the project is also used with **Claude Code on the web**
(claude.ai/code), because cloud sessions only see skills committed inside the repo.

### Troubleshooting

| Problem | Fix |
|---|---|
| `could not read Username for 'https://github.com'` | Run `gh auth login` and `gh auth setup-git`, then retry |
| `Repository not found` | You don't have access yet. Ask the repo admin |
| Skills don't appear after `/` | Reload VS Code / start a new session; check `ls ~/.claude/skills` |
| Two copies of a skill (e.g. `vue-architecture` and `team-vue:vue-architecture`) | You installed both ways. Keep one: remove the plugin (`/plugin`) **or** the folder in `~/.claude/skills` |
| You had a personal skill with the same name | The installer replaced it. Rename your personal skill if you need both |

---

## Maintenance guide (for skill maintainers)

### Change or add a skill

```bash
cd <your clone of claude-skills>
git pull
# edit files under plugins/team-vue/skills/<skill>/  (or add a new skill folder with a SKILL.md)
```

1. **Test locally** before pushing:
   ```bash
   SKIP_PULL=1 bash install.sh       # installs your working copy into ~/.claude/skills
   ```
   Reload VS Code and try a request that should use the skill.
2. **Bump the version** in `plugins/team-vue/.claude-plugin/plugin.json` (e.g. `1.1.0 → 1.2.0`).
   Set it only there, not in `marketplace.json`.
3. **Commit and push:**
   ```bash
   git add .
   git commit -m "vue-architecture: add pagination rule (v1.2.0)"
   git push
   ```
4. **Tell the team** to run `bash ~/claude-skills/install.sh`.

### Rules for skill files
- Every skill is a folder with a `SKILL.md` that starts with:
  ```yaml
  ---
  name: my-skill              # same as the folder name, lowercase-with-dashes
  description: What it does and when to use it.   # ≤ 200 characters (claude.ai limit)
  ---
  ```
- Keep `SKILL.md` short (under about 200 lines). Put details in `references/*.md` and code in
  `templates/`.
- No project secrets, credentials, personal data or internal URLs in skills.
- **Don't edit `skills/frappe-ui/`.** It's the official upstream reference. To upgrade it, follow
  `skills/frappe-ui/VERSION.md`, then update the pinned version in `vue-architecture`, rebuild
  the templates on the new version, and bump the plugin version.

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

## Repository layout

```
README.md
install.sh                              installer / updater for teammates
.claude-plugin/marketplace.json         plugin marketplace "team-skills" (optional install route)
plugins/team-vue/
  .claude-plugin/plugin.json            plugin "team-vue" + version
  skills/
    vue-architecture/                   SKILL.md, references/, templates/
    vue-common-components/              SKILL.md, references/, templates/
    dashboard-guide/                    SKILL.md, references/
    frappe-ui/                          official frappe-ui skill v1.2.0 (MIT, unchanged)
```

## Other ways to install

Use **one** method per machine, or Claude sees two copies of each skill.

**Claude Code plugin** (alternative to `install.sh`; skills appear as `team-vue:<skill>`):

```
/plugin marketplace add Tech4socialsector/claude-skills
/plugin install team-vue@team-skills          → choose "User" scope
```

Update with `/plugin marketplace update team-skills`, then `/plugin` → Installed → Update now.

**Claude.ai web chat:** turn on code execution in Settings → Capabilities, then zip each skill
folder and upload it under Customize → Skills → **+** → Create skill → Upload a skill:

```bash
cd ~/claude-skills/plugins/team-vue/skills
zip -r ~/vue-architecture.zip vue-architecture
zip -r ~/vue-common-components.zip vue-common-components
zip -r ~/dashboard-guide.zip dashboard-guide
```

Don't upload `frappe-ui` to claude.ai, because its description is over claude.ai's 200-character
limit. On a Team or Enterprise plan, an owner can provision the skills for everyone
(Organization settings → Plugins & skills).
