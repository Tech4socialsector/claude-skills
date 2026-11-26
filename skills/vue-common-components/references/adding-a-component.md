# Adding or Changing a Team Component

## Where does it go?

| Situation | Where |
|---|---|
| frappe-ui already has it (check the `frappe-ui` skill's CORE.md) | Use frappe-ui |
| Used by one page or feature | `components/<feature>/` |
| Used by 2+ features **and** domain-neutral | `components/common/` + catalogue entry |
| An existing team component almost fits | Add an optional prop or slot to it |

**Domain-neutral test:** could another team in a completely different domain use it unchanged?
If its name, props or text mention students, candidates, tickets, invoices and so on, it's a
feature component.

## Template

```vue
<template>
  <div class="rounded-6 border border-outline-gray-1 bg-surface-base p-4 text-ink-gray-8">
    <slot />
  </div>
</template>

<script setup>
const props = defineProps({
  // [{ key, label }] — document the shape of every array/object prop
  items: { type: Array, default: () => [] },
  modelValue: { type: String, default: '' },
  disabled: { type: Boolean, default: false },
})
const emit = defineEmits(['update:modelValue'])
</script>
```

## Rules
1. Build on frappe-ui parts (`Button`, `Dialog`, `List`, `TextInput`, …), not raw elements.
2. Props have a type and a default. Use `required` only when the component can't render
   without it.
3. `v-model` for values; `v-model:open` (`open` + `update:open`) for overlays.
4. Emit, don't mutate.
5. No fetching unless it's a self-contained widget that takes an ID, and then only through a
   service.
6. No business text. Labels come in through props or slots, with neutral defaults.
7. Semantic tokens, `lucide-*` icons, numbered radius. No hex or raw palette classes.
8. Accessible: labels, `aria-label` on icon-only buttons, keyboard support.
9. Works at 360px. ≤ 300 lines.

## Changing an existing component
1. `grep -rn "<ComponentName" src/` to find every usage.
2. Add behaviour behind a **new optional prop or slot** whose default keeps the current
   behaviour.
3. Don't rename or remove props or slots unless every usage is updated in the same change.
4. Check each page that uses it in the browser.
5. If the change affects the shared contract, update `catalogue.md` and the template in this
   skills repo, and tell the team.

## Document it
- Add a row to the Quick pick table in `SKILL.md`.
- Add a contract section to `references/catalogue.md`.
- If it's generally useful, add the file to `templates/`.
