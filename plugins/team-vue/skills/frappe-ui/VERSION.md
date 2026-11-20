# Source

These files (`SKILL.md`, `CORE.md`, `DATA.md`, `SETUP.md`) are the **official frappe-ui agent skill**,
copied unchanged from <https://github.com/frappe/frappe-ui/tree/v1.2.0/skills/frappe-ui>
at tag **v1.2.0**, which matches the team's pinned `frappe-ui@1.2.0`. They are licensed under MIT
(see `LICENSE.md`, © Frappe Technologies Pvt. Ltd.).

**Don't edit these files.** Put team rules in `vue-architecture` / `vue-common-components`.

To upgrade when the team moves to a new frappe-ui version, replace the four files from that
version's tag:

```bash
V=v1.3.0   # the new pinned version
for f in SKILL.md CORE.md DATA.md SETUP.md; do
  curl -fsSL "https://raw.githubusercontent.com/frappe/frappe-ui/$V/skills/frappe-ui/$f" -o "$f"
done
```

Then update the pinned version in `vue-architecture/SKILL.md` and `references/scaffold.md`.
