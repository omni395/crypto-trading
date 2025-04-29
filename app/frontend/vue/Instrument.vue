<template>
  <div class="flex flex-col border-b border-gray-600 py-2 hover:bg-gray-700 transition">
    <!-- Первая строка: иконка, название, процент изменения -->
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <span class="relative w-[20px] h-[20px] inline-block align-middle mr-2">
          <img
            :src="`https://cdn.jsdelivr.net/gh/vadimmalykhin/binance-icons/crypto/${instrument.base_asset?.toLowerCase()}.svg`"
            @error="showFallback($event)"
            :alt="instrument.base_asset"
            width="16"
            height="16"
            loading="lazy"
            class="inline-block align-middle rounded-full bg-gray-800 border border-gray-600"
            :id="`icon-${instrument.base_asset?.toLowerCase()}`"
            v-show="!fallbackIcon"
          />
          <i v-if="fallbackIcon" class="fa-solid fa-coins text-gray-500 align-middle"></i>
        </span>
        <span class="font-mono text-md text-white">{{ instrument.base_asset }}</span>
      </div>
      <div class="flex items-center justify-between">
        <span class="text-md" :style="{
          color: sortKey === 'change'
            ? (percentClass(instrument.price_change_percent) === 'text-green-400' ? '#4ade80' : percentClass(instrument.price_change_percent) === 'text-red-400' ? '#f87171' : '#a3a3a3')
            : (percentClass(instrument.price_change_percent) === 'text-green-400' ? '#b5f5cb' : percentClass(instrument.price_change_percent) === 'text-red-400' ? '#fbcaca' : '#d4d4d4'),
          fontWeight: sortKey === 'change' ? 'bold' : 'normal',
          textDecoration: sortKey === 'change' ? 'underline' : 'none',
          opacity: sortKey === 'change' ? 1 : 0.85
        }">{{ instrument.price_change_percent }}%</span>
      </div>
    </div>
    <!-- Вторая строка: изменение и котируемая монета -->
    <div class="flex items-center justify-between">
      <div class="text-xs text-gray-400 ml-7">{{ instrument.quote_asset }}</div>
      <div class="flex items-center justify-between ml-7 mt-0.5">
      <span class="font-semibold text-green-400 text-xs">
        <div class="flex items-center justify-between">
          <span class="text-xs font-mono" :style="{
            color: sortKey === 'price' ? '#fff' : '#d1d5db',
            fontWeight: sortKey === 'price' ? 'bold' : 'normal',
            textDecoration: sortKey === 'price' ? 'underline' : 'none',
            opacity: sortKey === 'price' ? 1 : 0.85
          }">{{ instrument.last_price }}</span>
        </div>
      </span>
    </div>
    </div>
    <!-- Объём и сделки в одну строку -->
    <div class="flex items-center gap-4 mt-1 ml-7">
      <span class="text-xs text-gray-400"><i class="fa-solid fa-chart-column"></i></span>
      <span class="text-xs" :style="{
        color: sortKey === 'volume' ? '#8ec5fe' : '#b8d4f8',
        fontWeight: sortKey === 'volume' ? 'bold' : 'normal',
        textDecoration: sortKey === 'volume' ? 'underline' : 'none',
        opacity: sortKey === 'volume' ? 1 : 0.85
      }">{{ formatNumber(instrument.volume) }}</span>
      <span class="text-xs text-gray-400 ml-3"><i class="fa-solid fa-money-bill-trend-up"></i></span>
      <span class="text-xs" :style="{
        color: sortKey === 'trades' ? '#c27bff' : '#e2cfff',
        fontWeight: sortKey === 'trades' ? 'bold' : 'normal',
        textDecoration: sortKey === 'trades' ? 'underline' : 'none',
        opacity: sortKey === 'trades' ? 1 : 0.85
      }">{{ formatNumber(instrument.trades) }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  instrument: {
    type: Object,
    required: true
  },
  sortKey: {
    type: String,
    default: 'alpha'
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
