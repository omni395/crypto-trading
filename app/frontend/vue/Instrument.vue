<template>
  <div
    class="instrument-row transition-all duration-200 ease-in-out p-3 mb-2 rounded-lg"
    :class="{
      'selected-instrument': selected,
      'hover-instrument': !selected
    }"
    @mouseenter="hovered = true"
    @mouseleave="hovered = false"
  >
    <!-- Первая строка: иконка, название, процент изменения -->
    <div class="flex items-center justify-between pr-3">
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
    <div class="flex items-center justify-between pr-3">
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
    <div class="flex items-center gap-4 mt-1 ml-7 pr-3">
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
  },
  selected: {
    type: Boolean,
    default: false
  }
})

const hovered = ref(false)
// fallbackIcon определяет, нужно ли показывать иконку-заглушку
const fallbackIcon = ref(false)

function showFallback(e) {
  fallbackIcon.value = true
}

function percentClass(percent) {
  if (percent > 0) return 'text-green-400'
  if (percent < 0) return 'text-red-400'
  return 'text-gray-400'
}

function formatNumber(val) {
  if (val == null) return '-'
  if (val > 1000000) return (val / 1000000).toFixed(1) + 'M'
  if (val > 1000) return (val / 1000).toFixed(1) + 'K'
  return val
}
</script>

<style scoped>
.instrument-row {
  border: 1px solid transparent;
}

.selected-instrument {
  background: linear-gradient(90deg, #183f2f 0%, #1f513c 100%);
  border: 2px solid #34d399;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transform: translateY(-2px);
  position: relative;
  z-index: 2;
}

.hover-instrument:hover {
  background: linear-gradient(90deg, #23272f 0%, #2e353f 100%);
  border-color: rgba(52, 211, 153, 0.3);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Убираем конфликтующие стили */
.selected-instrument:hover {
  background: linear-gradient(90deg, #183f2f 0%, #1f513c 100%);
}
</style>
