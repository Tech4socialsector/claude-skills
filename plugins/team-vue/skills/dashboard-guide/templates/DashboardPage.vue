<template>
  <!-- Team dashboard template (frappe-ui 1.2.0). Zones: header → filters → KPIs → detail.
       Replace labels, fields and buckets with your own; keep the structure and states. -->
  <div class="mx-auto max-w-6xl space-y-6 px-3 pb-10 pt-5 text-ink-gray-8 sm:px-5">
    <!-- 1 HEADER -->
    <header class="flex flex-wrap items-start justify-between gap-3">
      <div class="min-w-0">
        <h1 class="text-2xl-semibold text-ink-gray-9">Service requests</h1>
        <p class="mt-1 text-p-sm text-ink-gray-5">{{ scopeSentence }}</p>
      </div>
      <div class="flex items-center gap-2 text-sm text-ink-gray-5">
        <span v-if="summary.loading && summary.data" class="lucide-loader-circle size-4 animate-spin" aria-hidden="true" />
        <span v-if="summary.data?.as_of">Updated {{ formatTime(summary.data.as_of) }}</span>
        <Button icon="lucide-refresh-cw" aria-label="Refresh" :loading="summary.loading" @click="summary.reload()" />
      </div>
    </header>

    <!-- 2 FILTERS: draft values, applied only on Apply -->
    <section aria-label="Filters" class="space-y-2">
      <form class="flex flex-wrap items-end gap-2" @submit.prevent="filters.apply()">
        <div class="w-full sm:w-60">
          <DateRangePicker v-model="filters.draft.period" placeholder="Period" />
        </div>
        <div class="w-full sm:w-48">
          <MultiSelect v-model="filters.draft.region" :options="options.regions" placeholder="All regions" />
        </div>
        <div class="w-full sm:w-48">
          <MultiSelect v-model="filters.draft.unit" :options="unitOptions" placeholder="All units" />
        </div>
        <div class="w-full sm:w-44">
          <MultiSelect v-model="filters.draft.status" :options="options.statuses" placeholder="All statuses" />
        </div>
        <div class="flex items-center gap-2 sm:ml-auto">
          <Button type="button" variant="ghost" label="Reset" @click="filters.reset()" />
          <Button
            type="submit"
            variant="solid"
            theme="gray"
            :disabled="!filters.isDirty.value"
            :label="filters.isDirty.value ? `Apply ${filters.changedCount.value} change${filters.changedCount.value > 1 ? 's' : ''}` : 'Apply'"
          />
        </div>
      </form>
      <div v-if="filters.activeKeys.value.length" class="flex flex-wrap items-center gap-1.5 text-sm">
        <span class="text-ink-gray-5">Active:</span>
        <Badge v-for="key in filters.activeKeys.value" :key="key" theme="gray" variant="subtle" :label="chipLabel(key)">
          <template #suffix>
            <button type="button" class="ml-0.5 rounded-full" :aria-label="`Remove ${FILTER_LABELS[key]} filter`" @click="filters.clearFilter(key)">
              <span class="lucide-x size-3" aria-hidden="true" />
            </button>
          </template>
        </Badge>
      </div>
    </section>

    <ErrorMessage v-if="summary.error && !summary.data" :message="summary.error" />

    <!-- 3 KPIs: each is a button that opens its drilldown -->
    <section aria-label="Key figures" class="grid grid-cols-2 gap-4 lg:grid-cols-4" :class="{ 'opacity-60': refreshing }">
      <button
        v-for="kpi in kpis"
        :key="kpi.bucket"
        type="button"
        class="min-w-0 rounded-6 text-left transition-shadow hover:shadow-sm"
        :aria-label="`View ${kpi.title}`"
        @click="openDrilldown(kpi.bucket, kpi.title)"
      >
        <NumberCard
          :title="kpi.title"
          :value="kpi.value"
          :suffix="kpi.suffix"
          :negative-is-better="kpi.negativeIsBetter"
          :format="kpi.format"
          :loading="summary.loading && !summary.data"
        />
      </button>
    </section>

    <!-- 4 DETAIL: charts draw their own title, loading, error and empty states -->
    <!-- min-w-0 on every grid cell: without it a chart drawn at desktop width blocks shrinking -->
    <section class="grid grid-cols-1 gap-4 lg:grid-cols-3" :class="{ 'opacity-60': refreshing }">
      <div class="h-80 min-w-0 lg:col-span-2">
        <BarChart
          title="Requests by unit"
          subtitle="Top 10 · click a bar to see its records"
          :data="summary.data?.by_unit || []"
          x="unit"
          y="count"
          horizontal
          :loading="summary.loading && !summary.data"
          @select="(e) => openDrilldown('all', `Requests · ${e.row.unit}`, { unit: [e.row.unit] })"
        />
      </div>
      <div class="h-80 min-w-0">
        <DonutChart
          title="By status"
          :data="summary.data?.by_status || []"
          category="status"
          value="count"
          :loading="summary.loading && !summary.data"
        />
      </div>
    </section>

    <SectionCard :title="`Overdue requests (${summary.data?.action_total ?? '—'})`" description="Oldest due date first" icon="lucide-alarm-clock">
      <template #actions>
        <Button
          v-if="(summary.data?.action_total || 0) > (summary.data?.action_rows?.length || 0)"
          label="View all"
          icon-right="lucide-arrow-right"
          @click="openDrilldown('overdue', 'Overdue requests')"
        />
      </template>
      <DataTable
        :columns="rowColumns"
        :rows="summary.data?.action_rows || []"
        :loading="summary.loading && !summary.data"
        :searchable="false"
        min-width="560px"
        empty-title="Nothing overdue"
      >
        <template #cell-status="{ value }"><StatusBadge :status="value" /></template>
      </DataTable>
    </SectionCard>

    <!-- Drilldown: centred, header fixed, body scrolls, server-paginated -->
    <Dialog v-model:open="drill.open" :title="drill.title" size="5xl">
      <div class="space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2 text-sm text-ink-gray-5">
          <span>{{ drillCall.data?.total ?? 0 }} records · {{ scopeSentence }}</span>
          <Button v-if="summary.data?.can_export" label="Export CSV" icon-left="lucide-download" :loading="drill.exporting" @click="exportDrill" />
        </div>
        <ErrorMessage v-if="drillCall.error" :message="drillCall.error" />
        <div class="max-h-[60vh] overflow-y-auto">
          <DataTable :columns="rowColumns" :rows="drillCall.data?.rows || []" :loading="drillCall.loading" :searchable="false" min-width="560px">
            <template #cell-status="{ value }"><StatusBadge :status="value" /></template>
          </DataTable>
        </div>
        <div v-if="(drillCall.data?.total || 0) > PAGE" class="flex items-center justify-end gap-2">
          <Button label="Previous" :disabled="drill.start === 0" @click="loadDrill(drill.start - PAGE)" />
          <Button label="Next" :disabled="drill.start + PAGE >= (drillCall.data?.total || 0)" @click="loadDrill(drill.start + PAGE)" />
        </div>
      </div>
    </Dialog>
  </div>
</template>

<script setup>
import { computed, reactive } from 'vue'
import dayjs from 'dayjs'
import { Badge, Button, DateRangePicker, Dialog, ErrorMessage, MultiSelect } from 'frappe-ui'
import { BarChart, DonutChart, NumberCard } from 'frappe-ui/charts'
import DataTable from '@/components/common/DataTable.vue'
import SectionCard from '@/components/common/SectionCard.vue'
import StatusBadge from '@/components/common/StatusBadge.vue'
import { dashboardApi } from '@/services/dashboard'
import { useDashboardFilters } from '@/composables/useDashboardFilters'
import { notify } from '@/utils/notify'

const PAGE = 50
const FILTER_LABELS = { period: 'Period', region: 'Region', unit: 'Unit', status: 'Status' }
const number = new Intl.NumberFormat(undefined)

// ---- filter options (cached) and dependent unit list
const optionsCall = dashboardApi.filterOptions()
const options = computed(() => optionsCall.data || { regions: [], units: [], statuses: [] })
const allowedUnits = (draft) => {
  if (!optionsCall.data) return null
  const units = optionsCall.data.units
  return (draft.region.length ? units.filter((u) => draft.region.includes(u.region)) : units).map((u) => u.value)
}

// ---- draft vs applied filters; default = this month
const filters = useDashboardFilters(
  {
    period: [dayjs().startOf('month').format('YYYY-MM-DD'), dayjs().format('YYYY-MM-DD')],
    region: [],
    unit: [],
    status: [],
  },
  { dependents: { unit: { allowed: allowedUnits } } },
)
const unitOptions = computed(() => {
  const allowed = new Set(allowedUnits(filters.draft) || [])
  return options.value.units.filter((u) => allowed.has(u.value)).map(({ label, value }) => ({ label, value }))
})

// ---- one request per Apply (refetch follows the applied filters)
const summary = dashboardApi.summary({
  params: () => ({ filters: JSON.stringify(filters.applied.value) }),
  refetch: true,
})
const refreshing = computed(() => summary.loading && !!summary.data)

const kpis = computed(() => {
  const k = summary.data?.kpis || {}
  return [
    { bucket: 'all', title: 'Total requests', value: k.total ?? null, format: (v) => number.format(v) },
    { bucket: 'completed', title: 'Completion rate', value: k.completion_rate ?? null, suffix: '%' },
    { bucket: 'pending', title: 'Pending', value: k.pending ?? null, negativeIsBetter: true, format: (v) => number.format(v) },
    { bucket: 'overdue', title: 'Overdue', value: k.overdue ?? null, negativeIsBetter: true, format: (v) => number.format(v) },
  ]
})

const rowColumns = [
  { key: 'name', label: 'ID', width: '9rem' },
  { key: 'subject', label: 'Subject' },
  { key: 'unit', label: 'Unit', width: '10rem' },
  { key: 'status', label: 'Status', width: '8rem' },
  { key: 'due_date', label: 'Due', width: '8rem', align: 'right', format: (r) => (r.due_date ? dayjs(r.due_date).format('DD MMM YYYY') : '—') },
]

// ---- scope sentence + chips, from APPLIED filters only
const scopeSentence = computed(() => {
  const a = filters.applied.value
  const [from, to] = a.period || []
  const period = from && to ? `${dayjs(from).format('D MMM YYYY')} – ${dayjs(to).format('D MMM YYYY')}` : 'All time'
  return `${a.unit.length ? `${a.unit.length} unit(s)` : a.region.length ? `${a.region.length} region(s)` : 'All permitted units'} · ${period}`
})
function chipLabel(key) {
  const v = filters.applied.value[key]
  if (key === 'period') return `Period: ${dayjs(v[0]).format('D MMM')} – ${dayjs(v[1]).format('D MMM')}`
  return `${FILTER_LABELS[key]}: ${v.length > 2 ? `${v.length} selected` : v.join(', ')}`
}
const formatTime = (value) => dayjs(value).format('D MMM, HH:mm')

// ---- drilldown: same applied filters + the clicked bucket (+ optional extra filter)
const drillCall = dashboardApi.drilldown()
const drill = reactive({ open: false, title: '', bucket: 'all', extra: {}, start: 0, exporting: false })

function drillFilters() {
  return JSON.stringify({ ...filters.applied.value, ...drill.extra })
}
async function loadDrill(start = 0) {
  drill.start = Math.max(start, 0)
  try {
    await drillCall.submit({ bucket: drill.bucket, filters: drillFilters(), start: drill.start, page_length: PAGE })
  } catch {
    /* shown by <ErrorMessage :message="drillCall.error" /> */
  }
}
function openDrilldown(bucket, title, extra = {}) {
  Object.assign(drill, { open: true, title, bucket, extra })
  loadDrill(0)
}
async function exportDrill() {
  drill.exporting = true
  try {
    await dashboardApi.exportCsv({ bucket: drill.bucket, filters: drillFilters() })
  } catch (err) {
    notify.error(err)
  } finally {
    drill.exporting = false
  }
}
</script>
