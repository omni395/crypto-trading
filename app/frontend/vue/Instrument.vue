<template>
  <div class="flex flex-col border-b border-gray-600 py-2 px-4 hover:bg-gray-700 transition">
    <!-- Первая строка: иконка, название, процент изменения -->
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <span class="relative w-[20px] h-[20px] inline-block align-middle mr-2">
          <img
            :src="`https://cdn.jsdelivr.net/gh/vadimmalykhin/binance-icons/crypto/${instrument.base_asset?.toLowerCase()}.svg`"
            @error="showFallback($event)"
            :alt="instrument.base_asset"
            width="20"
            height="20"
            loading="lazy"
            class="inline-block align-middle rounded-full bg-gray-800 border border-gray-600"
            :id="`icon-${instrument.base_asset?.toLowerCase()}`"
            v-show="!fallbackIcon"
          />
          <i v-if="fallbackIcon" class="fa-solid fa-coins text-gray-500 align-middle"></i>
        </span>
        <span class="font-mono text-lg text-white">{{ instrument.base_asset }}</span>
      </div>
      <div class="text-lg" :class="percentClass(instrument.price_change_percent)">
        {{ instrument.price_change_percent }}%
      </div>
    </div>
    <!-- Вторая строка: изменение и котируемая монета -->
    <div class="flex items-center justify-between">
      <div class="text-xs text-gray-400 ml-7">{{ instrument.quote_asset }}</div>
      <div class="flex items-center justify-between ml-7 mt-0.5">
      <span class="font-semibold text-green-400 text-xs">{{ instrument.last_price }}</span>
    </div>
    </div>
    <!-- Далее: объем, сделки -->
    <div class="flex flex-col mt-1 ml-7 gap-0.5">
      <div class="flex items-center justify-between">
        <span class="text-xs text-gray-400">Объём:</span>
        <span class="text-xs text-blue-300">{{ formatNumber(instrument.volume) }}</span>
      </div>
      <div class="flex items-center justify-between">
        <span class="text-xs text-gray-400">Сделок:</span>
        <span class="text-xs text-purple-300">{{ formatNumber(instrument.trades) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  instrument: {
    type: Object,
    required: true
  }
})

// fallbackIcon определяет, нужно ли показывать иконку-заглушку
const fallbackIcon = ref(false)

function showFallback(event) {
  fallbackIcon.value = true
  event.target.style.display = 'none'
}

// Форматирование чисел с разделителями
function formatNumber(value) {
  if (typeof value === 'number') {
    return value.toLocaleString('ru-RU')
  }
  if (!isNaN(Number(value))) {
    return Number(value).toLocaleString('ru-RU')
  }
  return value
}

// Определение цвета для процента изменения
function percentClass(percent) {
  if (Number(percent) > 0) return 'text-green-400'
  if (Number(percent) < 0) return 'text-red-400'
  return 'text-gray-400'
}
</script>
