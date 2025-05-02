<template>
  <div class="main-view">
    <div v-if="instrument">
      <div class="text-2xl text-white mb-2">
        {{ instrument.symbol }}
        {{ instrument.exchange }}
      </div>
      
      <!-- Верхний ряд -->
      <div class="flex gap-2 mb-2">
        <!-- Основной график (2/3 ширины) -->
        <div class="w-2/3 bg-gray-900">
          <MainChart :instrument="instrument" />
        </div>
        
        <!-- Правая колонка (1/3 ширины) -->
        <div class="w-1/3 flex flex-col gap-2">
          <div class="bg-gray-900 flex-1">
            <div class="text-white p-2">Часовой график (1H)</div>
            <div class="chart-area h-[180px]"></div>
          </div>
          <div class="bg-gray-900 flex-1">
            <div class="text-white p-2">Дневной график (1D)</div>
            <div class="chart-area h-[180px]"></div>
          </div>
        </div>
      </div>

      <!-- Нижний ряд -->
      <div class="flex gap-2">
        <div class="w-1/2 bg-gray-900">
          <div class="text-white p-2">Гистограмма 1</div>
          <div class="chart-area h-[180px]"></div>
        </div>
        <div class="w-1/2 bg-gray-900">
          <div class="text-white p-2">Гистограмма 2</div>
          <div class="chart-area h-[180px]"></div>
        </div>
      </div>
    </div>
    <div v-else class="flex items-center justify-center h-full">
      <i class="fa-solid fa-coins text-gray-400 text-6xl"></i>
    </div>
  </div>
</template>

<script setup>
import MainChart from './components/charts/MainChart.vue'
const props = defineProps({
  instrument: {
    type: Object,
    required: false,
    default: null
  }
})
</script>

<style scoped>
.main-view {
  height: 100%;
}

.chart-area {
  width: 100%;
}
</style>
