<template>
  <div class="flex flex-col border-b border-gray-600 py-2 px-4 hover:bg-gray-700 transition">
    <!-- Первая строка: иконка, название, цена -->
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
      <span class="font-semibold text-green-400 text-lg">{{ instrument.last_price }}</span>
    </div>
    <!-- Вторая строка: котируемая монета -->
    <div class="text-xs text-gray-400 ml-7">{{ instrument.quote_asset }}</div>
    <!-- Третья и далее: объем, сделки, изменение -->
    <div class="flex flex-col mt-1 ml-7">
      <span class="text-xs text-gray-400">Объём: {{ instrument.volume }}</span>
      <span class="text-xs text-gray-400">Сделок: {{ instrument.trades }}</span>
      <span class="text-xs text-blue-400">Изм. 24ч: {{ instrument.price_change_percent }}%</span>
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
</script>
