<template>
  <!-- frappe-ui has no Card: this is the token-built card surface. -->
  <section class="rounded-6 border border-outline-gray-1 bg-surface-base text-ink-gray-8">
    <header
      v-if="title || $slots.actions"
      class="flex flex-wrap items-center justify-between gap-2 border-b border-outline-gray-1 px-4 py-3"
    >
      <div class="flex min-w-0 items-center gap-2.5">
        <span v-if="icon" :class="[icon, 'size-4 shrink-0 text-ink-gray-6']" aria-hidden="true" />
        <div class="min-w-0">
          <h2 v-if="title" class="truncate text-lg-semibold text-ink-gray-8">{{ title }}</h2>
          <p v-if="description" class="mt-0.5 text-p-sm text-ink-gray-5">{{ description }}</p>
        </div>
      </div>
      <div v-if="$slots.actions" class="flex shrink-0 flex-wrap items-center gap-2">
        <slot name="actions" />
      </div>
    </header>
    <div class="p-4">
      <slot />
    </div>
  </section>
</template>

<script setup>
defineProps({
  title: { type: String, default: '' },
  description: { type: String, default: '' },
  // lucide-* class, e.g. 'lucide-folder'
  icon: { type: String, default: '' },
})
</script>
