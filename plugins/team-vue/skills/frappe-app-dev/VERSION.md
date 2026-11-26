# Source

`SKILL.md` is the **official Frappe `frappe-app-dev` agent skill**, copied unchanged from
<https://github.com/frappe/skills/tree/d213dce39942c969293e9fe7feb96ab33cbba25c/skills/frappe-app-dev>
(commit `d213dce`, 2026-11-13). The upstream repo has no license file; © Frappe Technologies Pvt. Ltd.
Keep this repo private while it is vendored here.

It assumes Frappe's **Pilot** CLI (`pilot frappe --site SITE …`). On a plain `bench` setup, read
`pilot frappe` as `bench` and `pilot start` as `bench start`; the Code and Tests sections apply as-is.

**Don't edit this file.** Put team rules in another skill.

To update to the latest upstream version:

```bash
curl -fsSL https://raw.githubusercontent.com/frappe/skills/main/skills/frappe-app-dev/SKILL.md -o SKILL.md
```

Then update the commit above and bump the plugin version.
