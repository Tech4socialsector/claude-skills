<template>
  <div class="flex flex-col items-center justify-center gap-3 px-3 py-16 text-center">
    <div class="rounded-full bg-surface-gray-2 p-3 text-ink-gray-5">
      <span :class="[icon, 'block size-6']" aria-hidden="true" />
    </div>
    <p class="text-base text-ink-gray-7">{{ title }}</p>
    <p v-if="description" class="max-w-md text-p-sm text-ink-gray-5">{{ description }}</p>
    <div v-if="$slots.action" class="mt-2">
      <slot name="action" />
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  description: { type: String, default: '' },
  // lucide-* class
  icon: { type: String, default: 'lucide-inbox' },
})
</script>
