<template>
  <div class="flex items-center justify-between border-b border-gray-600 py-2 px-4 hover:bg-gray-700 transition">
    <div class="flex flex-col">
      <div class="flex items-center">
        <span class="relative w-[20px] h-[20px] inline-block align-middle mr-2">
          <img :src="`https://cdn.jsdelivr.net/gh/vadimmalykhin/binance-icons/crypto/${instrument.base_asset?.toLowerCase()}.svg`"
               :onerror="`this.onerror=null;this.src='https://cryptoicons.org/api/icon/${instrument.base_asset?.toLowerCase()}/32';this.onerror=function(){this.style.display='none';this.nextElementSibling.style.display='inline-block';}`"
               :alt="instrument.base_asset"
               width="20"
               height="20"
               loading="lazy"
               class="inline-block align-middle rounded-full bg-gray-800 border border-gray-600"
               :id="`icon-${instrument.base_asset?.toLowerCase()}`" />
          <span style="display:none;position:absolute;left:0;top:0;" 
                class="w-[20px] h-[20px] text-gray-500 fa-solid fa-circle-question align-middle">
          </span>
        </span>
        <span class="font-mono text-lg text-white">{{ instrument.base_asset }}</span>
      </div>
      <span class="text-xs text-gray-400">{{ instrument.quote_asset }}</span>
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
