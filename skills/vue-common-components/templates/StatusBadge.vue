<template>
  <Badge v-if="status" :theme="theme" :size="size" :label="label || status" />
</template>

<script setup>
// Status pill. Colours come from src/config/statuses.js — add new statuses there,
// never special-case them in pages.
import { computed } from 'vue'
import { Badge } from 'frappe-ui'
import { STATUS_TONES } from '@/config/statuses'

const props = defineProps({
  status: { type: String, default: '' },
  // Display text when it differs from the stored status.
  label: { type: String, default: '' },
  // Optional per-use override: { 'Some Status': 'green' }
  tones: { type: Object, default: null },
  // sm | md | lg
  size: { type: String, default: 'sm' },
})

const theme = computed(() => props.tones?.[props.status] || STATUS_TONES[props.status] || 'gray')
</script>
