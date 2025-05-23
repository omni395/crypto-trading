<template>
  <div
    class="instrument-row mr-2 mt-0.5 p-1.5 rounded-md"
    :class="{
      'selected-instrument': selected,
      'hover-instrument': !selected
    }"
    @mouseenter="hovered = true"
    @mouseleave="hovered = false"
  >
    <!-- Первая строка: иконка, название, процент изменения -->
    <div class="flex items-center justify-between pr-3">
      <div class="flex items-center gap-2">
        <span class="relative w-[20px] h-[20px] flex items-center justify-center">
          <img
            :src="`https://cdn.jsdelivr.net/gh/vadimmalykhin/binance-icons/crypto/${instrument.base_asset?.toLowerCase()}.svg`"
            @error="showFallback($event)"
            :alt="instrument.base_asset"
            width="16"
            height="16"
            loading="lazy"
            class="rounded-full bg-gray-800 border border-gray-600"
            :id="`icon-${instrument.base_asset?.toLowerCase()}`"
            v-show="!fallbackIcon"
          />
          <i v-if="fallbackIcon" class="fa-solid fa-coins text-gray-500"></i>
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
    <!-- Вторая строка: цена и котируемая монета -->
    <div class="flex items-center justify-between pr-3 mt-0.5">
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
    <!-- Третья строка: Объём и сделки в одну строку -->
    <div class="flex mt-0.5 items-center justify-between pr-3">
      <div>
        <span class="text-xs text-gray-400 mr-1"><i class="fa-solid fa-chart-column"></i></span>
        <span class="text-xs" :style="{
          color: sortKey === 'volume' ? '#8ec5fe' : '#b8d4f8',
          fontWeight: sortKey === 'volume' ? 'bold' : 'normal',
          textDecoration: sortKey === 'volume' ? 'underline' : 'none',
          opacity: sortKey === 'volume' ? 1 : 0.85
        }">{{ formatNumber(instrument.volume) }}</span>
      </div>
      <div>
        <span class="text-xs text-gray-400 mr-1"><i class="fa-solid fa-money-bill-trend-up"></i></span>
        <span class="text-xs" :style="{
          color: sortKey === 'trades' ? '#c27bff' : '#e2cfff',
          fontWeight: sortKey === 'trades' ? 'bold' : 'normal',
          textDecoration: sortKey === 'trades' ? 'underline' : 'none',
          opacity: sortKey === 'trades' ? 1 : 0.85
        }">{{ formatNumber(instrument.trades) }}</span>
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
  box-sizing: border-box;
  transition: background 0.2s, border-color 0.2s, color 0.2s;
}

.selected-instrument {
  background: linear-gradient(90deg, #183f2f 0%, #1f513c 100%);
  border: 1px solid #34d399;
}

.hover-instrument {
  border: 1px solid rgba(52, 211, 153, 0.3);
}

.hover-instrument:hover {
  background: linear-gradient(90deg, #23272f 0%, #2e353f 100%);
  border: 1px solid rgba(52, 211, 153, 0.3);
}
</style>
