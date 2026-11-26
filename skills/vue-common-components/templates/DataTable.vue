<template>
  <div class="space-y-3">
    <div v-if="searchable || $slots.toolbar" class="flex flex-wrap items-center gap-2">
      <TextInput
        v-if="searchable"
        v-model="query"
        type="search"
        class="w-full sm:w-72"
        :placeholder="searchPlaceholder"
        aria-label="Search"
      >
        <template #prefix><span class="lucide-search size-4 text-ink-gray-5" aria-hidden="true" /></template>
      </TextInput>
      <div v-if="$slots.toolbar" class="flex flex-wrap items-center gap-2 sm:ml-auto">
        <slot name="toolbar" />
      </div>
    </div>

    <div v-if="loading && !rows.length" class="space-y-2" aria-busy="true">
      <Skeleton v-for="i in 5" :key="i" class="h-9 w-full" />
    </div>

    <slot v-else-if="!visibleRows.length" name="empty">
      <EmptyState :title="query ? 'No matching records' : emptyTitle" :icon="query ? 'lucide-search-x' : 'lucide-inbox'" />
    </slot>

    <!-- Wide tables scroll sideways inside this box, never the page. -->
    <div v-else class="overflow-x-auto">
      <div :style="minWidth ? { minWidth } : null">
        <List :columns="tracks">
          <ListHeader>
            <template v-for="col in columns" :key="col.key">
              <ListHeaderCellSort
                v-if="col.sortable !== false"
                :direction="sortKey === col.key ? sortDir : null"
                :align="col.align === 'right' ? 'end' : 'start'"
                @click="toggleSort(col.key)"
              >
                {{ col.label }}
              </ListHeaderCellSort>
              <ListHeaderCell v-else>{{ col.label }}</ListHeaderCell>
            </template>
            <ListHeaderCell v-if="$slots.actions"><span class="sr-only">Actions</span></ListHeaderCell>
          </ListHeader>

          <ListRows v-slot="{ item, value }" :items="visibleRows" :row-key="rowKey">
            <ListRow :value="value" :route="rowRoute ? rowRoute(item) : undefined" v-bind="rowClickBinding(item)">
              <ListCell
                v-for="col in columns"
                :key="col.key"
                :class="col.align === 'right' ? 'justify-end tabular-nums' : ''"
              >
                <slot :name="`cell-${col.key}`" :row="item" :value="item[col.key]">
                  <span class="truncate text-base text-ink-gray-7">{{ display(item, col) }}</span>
                </slot>
              </ListCell>
              <ListCell v-if="$slots.actions" class="justify-end">
                <slot name="actions" :row="item" />
              </ListCell>
            </ListRow>
          </ListRows>
        </List>
      </div>
    </div>

    <p v-if="!loading && rows.length" class="text-sm text-ink-gray-5">
      {{ visibleRows.length }} of {{ rows.length }} records
    </p>
  </div>
</template>

<script setup>
// Team DataTable: table-mode wrapper over frappe-ui/list with client-side search + sort.
// For more than ~2,000 rows, page on the server with useList instead (see catalogue.md).
// Don't combine #actions with rowRoute/clickable — the row is already a link/button.
import { computed, ref, useSlots } from 'vue'
import { Skeleton, TextInput } from 'frappe-ui'
import { List, ListCell, ListHeader, ListHeaderCell, ListHeaderCellSort, ListRow, ListRows } from 'frappe-ui/list'
import EmptyState from './EmptyState.vue'

const props = defineProps({
  // [{ key, label, width?: '12rem', sortable?: true, align?: 'right', format?: (row) => string }]
  columns: { type: Array, required: true },
  rows: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  rowKey: { type: String, default: 'name' },
  // (row) => route location; rows render as links
  rowRoute: { type: Function, default: null },
  // emit row-click instead of navigating (ignored when rowRoute is set)
  clickable: { type: Boolean, default: false },
  searchable: { type: Boolean, default: true },
  searchPlaceholder: { type: String, default: 'Search' },
  emptyTitle: { type: String, default: 'No records yet' },
  // e.g. '720px' — below this width the table scrolls inside its box
  minWidth: { type: String, default: '' },
  actionsWidth: { type: String, default: '6rem' },
})
const emit = defineEmits(['row-click'])
const slots = useSlots()

if (import.meta.env.DEV && slots.actions && (props.rowRoute || props.clickable)) {
  console.warn('[DataTable] #actions cannot be combined with rowRoute/clickable (nested interactive elements).')
}

const query = ref('')
const sortKey = ref('')
const sortDir = ref('asc') // 'asc' | 'desc'

const tracks = computed(() => {
  const cols = props.columns.map((c) => c.width || 'minmax(0,1fr)')
  return slots.actions ? [...cols, props.actionsWidth] : cols
})

function rowClickBinding(item) {
  return !props.rowRoute && props.clickable ? { onClick: () => emit('row-click', item) } : {}
}

function display(row, col) {
  const value = col.format ? col.format(row) : row[col.key]
  return value ?? ''
}

function toggleSort(key) {
  if (sortKey.value !== key) {
    sortKey.value = key
    sortDir.value = 'asc'
  } else if (sortDir.value === 'asc') {
    sortDir.value = 'desc'
  } else {
    sortKey.value = '' // third click clears the sort
  }
}

const isEmpty = (v) => v === null || v === undefined || v === ''

function compare(a, b) {
  if (typeof a === 'number' && typeof b === 'number') return a - b
  return String(a).localeCompare(String(b), undefined, { numeric: true, sensitivity: 'base' })
}

const visibleRows = computed(() => {
  let out = props.rows
  const q = query.value.trim().toLowerCase()
  if (q) {
    out = out.filter((row) => props.columns.some((col) => String(display(row, col)).toLowerCase().includes(q)))
  }
  if (sortKey.value) {
    const key = sortKey.value
    const dir = sortDir.value === 'asc' ? 1 : -1
    out = [...out].sort((x, y) => {
      const a = x[key]
      const b = y[key]
      if (isEmpty(a) && isEmpty(b)) return 0
      if (isEmpty(a)) return 1 // empty values always last
      if (isEmpty(b)) return -1
      return compare(a, b) * dir
    })
  }
  return out
})
</script>
