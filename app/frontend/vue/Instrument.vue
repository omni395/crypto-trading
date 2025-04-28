<template>
  <div class="flex items-center justify-between border-b border-gray-600 py-2 px-4 hover:bg-gray-700 transition">
    <div class="flex flex-col">
      <span class="font-mono text-lg text-white">{{ instrument.symbol }}</span>
      <span class="text-xs text-gray-400">{{ instrument.exchange }} / {{ instrument.quote_asset }}</span>
      <span class="text-xs text-gray-400">Статус: {{ instrument.status }}</span>
    </div>
    <div class="flex flex-col text-right">
      <span class="font-semibold text-green-400">{{ instrument.last_price }}</span>
      <span class="text-xs text-gray-400">Объём: {{ instrument.volume }}</span>
      <span class="text-xs text-gray-400">Сделок: {{ instrument.trades }}</span>
      <span class="text-xs text-blue-400">Изм. 24ч: {{ instrument.price_change_percent }}%</span>
    </div>
  </div>
</template>

<script setup>
// Пропсы одной монеты
const props = defineProps({
  instrument: {
    type: Object,
    required: true
  }
})
</script>
