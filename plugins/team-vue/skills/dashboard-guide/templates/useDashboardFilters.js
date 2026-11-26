// src/composables/useDashboardFilters.js
// Draft vs applied filter state for dashboards (team template, frappe-ui 1.2.0 projects).
//
// - `draft` is bound to the filter controls; changing it fetches nothing.
// - `applied` is what every card, chart, table and drilldown reads. It changes only on apply().
// - `dependents` keeps child filters valid when a parent changes (State → District → Block).
//
// Filter values must be JSON-safe (strings, numbers, arrays of those). Dates as 'YYYY-MM-DD'.
import { computed, reactive, ref, watch } from 'vue'

const clone = (value) => JSON.parse(JSON.stringify(value))
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b)

/**
 * @param {Record<string, any>} defaults  initial value of every filter (arrays for multi-selects)
 * @param {{ dependents?: Record<string, { allowed: (draft) => any[] | null }> }} options
 *   dependents[child].allowed(draft) returns the child values that are valid for the current
 *   draft parents (or null while options are loading). Invalid selections are removed.
 */
export function useDashboardFilters(defaults, { dependents = {} } = {}) {
  const draft = reactive(clone(defaults))
  const applied = ref(clone(defaults))

  const changedKeys = computed(() =>
    Object.keys(defaults).filter((key) => !same(draft[key], applied.value[key])),
  )
  const isDirty = computed(() => changedKeys.value.length > 0)

  /** Copy draft → applied. Everything that reads `applied` refetches once. */
  function apply() {
    if (isDirty.value) applied.value = clone(draft)
  }

  /** Back to defaults, applied immediately. */
  function reset() {
    Object.assign(draft, clone(defaults))
    applied.value = clone(defaults)
  }

  /** Remove one active filter (chip ×) and apply. */
  function clearFilter(key) {
    draft[key] = clone(defaults[key])
    applied.value = { ...applied.value, [key]: clone(defaults[key]) }
  }

  /** Applied filters that differ from their defaults, for the "Active:" chip row. */
  const activeKeys = computed(() =>
    Object.keys(defaults).filter((key) => !same(applied.value[key], defaults[key])),
  )

  // Keep children consistent with their parents.
  for (const [child, { allowed }] of Object.entries(dependents)) {
    watch(
      () => allowed(draft),
      (values) => {
        if (!Array.isArray(values)) return // options not loaded yet
        const valid = new Set(values)
        const current = draft[child]
        if (Array.isArray(current)) {
          const kept = current.filter((v) => valid.has(v))
          if (kept.length !== current.length) draft[child] = kept
        } else if (current !== '' && current != null && !valid.has(current)) {
          draft[child] = clone(defaults[child])
        }
      },
    )
  }

  return { draft, applied, isDirty, changedCount: computed(() => changedKeys.value.length), activeKeys, apply, reset, clearFilter }
}
