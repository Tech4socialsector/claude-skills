# Team Skills for Claude Code

Shared Claude Code skills for building Vue 3 + frappe-ui frontends the same way across all our
projects, whatever the domain.

## What's inside

```
.claude-plugin/marketplace.json        marketplace "team-skills"
plugins/team-vue/
  .claude-plugin/plugin.json           plugin "team-vue" (v1.0.0)
  skills/
    vue-architecture/                  team structure: layers, data flow, access, backend rules, scaffold
    vue-common-components/             which component to use + team components (templates & contracts)
    frappe-ui/                         official frappe-ui skill, v1.2.0 (unchanged, MIT)
```

| Skill | Claude uses it when… |
|---|---|
| `vue-architecture` | adding or changing pages, routes, composables, services, stores or API calls, or scaffolding a new Vue frontend |
| `vue-common-components` | building any screen: tables, badges, cards, dialogs, filters, pickers, charts, empty states |
| `frappe-ui` | writing any frappe-ui markup (exact props, slots, tokens, data composables) |

## Pinned stack

| Package | Version |
|---|---|
| frappe-ui | **1.2.0** (exact pin) |
| vue / vue-router / pinia | ^3.5 / ^4.5 / ^3.0 |
| vite / @vitejs/plugin-vue | ^7.3 / ^6.0 |
| tailwindcss | ^3.4 (not v4) |
| Node | ≥ 20.19 |
| Frappe | v15+ |

All templates were built and rendered on this exact stack with no console errors or Vue
warnings. Older apps on frappe-ui `0.1.x` are covered by
`vue-architecture/references/legacy-0.1.md`.

---

## Install

Replace `<org>/claude-skills` with the real GitHub repo. The repo can be private; each teammate
needs read access, and git on their machine must already be logged in (`gh auth login`, then
`gh auth setup-git`).

### 1. Claude Code: terminal CLI or VS Code extension (recommended: plugin)

```
/plugin marketplace add <org>/claude-skills
/plugin install team-vue@team-skills          (choose "User" scope = all your projects)
```

Or from a shell:

```bash
claude plugin marketplace add <org>/claude-skills
claude plugin install team-vue@team-skills --scope user
```

- **Updates:** `/plugin marketplace update team-skills`, then `/plugin` → Installed → Update now
  (or `claude plugin update team-vue@team-skills`).
- **Check:** type `/` in Claude Code and look for `team-vue:vue-architecture`.
- **One project only:** use `--scope project` and commit `.claude/settings.json`. Each teammate
  still runs the install once per clone.

### 2. Claude Code without plugins: install script (simplest)

```bash
git clone https://github.com/<org>/claude-skills.git ~/claude-skills
bash ~/claude-skills/install.sh                 # copies the skills into ~/.claude/skills
# update later (same command):
bash ~/claude-skills/install.sh                 # git pull + re-copy
# one project only:
TARGET=/path/to/project/.claude/skills bash ~/claude-skills/install.sh
```

Manual equivalent:

```bash
git clone https://github.com/<org>/claude-skills.git ~/claude-skills
mkdir -p ~/.claude/skills
cp -r ~/claude-skills/plugins/team-vue/skills/* ~/.claude/skills/
# to update later:  cd ~/claude-skills && git pull && cp -r plugins/team-vue/skills/* ~/.claude/skills/
```

### 3. Claude Code on the web (claude.ai/code)

Cloud sessions **don't load plugins or `~/.claude/skills`**. They only see skills committed
inside the project repo:

```bash
cd <project-repo>
mkdir -p .claude/skills
cp -r ~/claude-skills/plugins/team-vue/skills/* .claude/skills/
git add .claude/skills && git commit -m "Add team Vue skills" && git push
```

Skills enabled on claude.ai (section 4) also load in cloud sessions.

### 4. Claude.ai web app (chat)

You need code execution enabled (Settings → Capabilities). Upload each skill as a ZIP whose
root is the skill folder:

```bash
cd ~/claude-skills/plugins/team-vue/skills
zip -r ~/vue-architecture.zip vue-architecture
zip -r ~/vue-common-components.zip vue-common-components
```

In claude.ai, go to Customize → Skills → **+** → Create skill → **Upload a skill**, and upload
each ZIP. Uploaded skills are personal. On a Team or Enterprise plan, an owner can provision
them for everyone (Organization settings → Plugins & skills).

> **Don't upload the `frappe-ui` folder to claude.ai.** Its description is longer than the
> 200-character limit there. Claude Code has no such limit, so keep it in sections 1–3.

## Maintaining

- **Change a team rule:** edit the files under `vue-architecture/` or
  `vue-common-components/`, bump `version` in `plugins/team-vue/.claude-plugin/plugin.json`
  (only there, not in `marketplace.json`), commit and push. Teammates then run
  `/plugin marketplace update team-skills`.
- **Add a team component:** follow `vue-common-components/references/adding-a-component.md`.
  Add the template under `templates/` and its contract to `references/catalogue.md`.
- **Upgrade frappe-ui:** follow `skills/frappe-ui/VERSION.md`. Replace the official files from
  the new tag, update the pinned version in `vue-architecture/SKILL.md` and
  `references/scaffold.md`, rebuild the templates on the new version, then bump the plugin
  version.
- **Don't edit `skills/frappe-ui/`** except during an upgrade. It's the upstream reference.
- **Add a new skill** (e.g. `security-checklist`, `dashboard-guide`): create
  `plugins/team-vue/skills/<name>/SKILL.md` with `name` and `description` frontmatter, or start
  a new plugin under `plugins/` and list it in `marketplace.json`.
