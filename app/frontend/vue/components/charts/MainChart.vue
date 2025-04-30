<template>
  <div ref="chartContainer" class="chart-area h-[380px]"></div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { createChart } from 'lightweight-charts'

const chartContainer = ref(null)

onMounted(() => {
  const chart = createChart(chartContainer.value, {
    width: chartContainer.value.clientWidth,
    height: chartContainer.value.clientHeight,
    layout: {
      background: { color: '#1f2937' },
      textColor: '#d1d5db',
    },
    grid: {
      vertLines: { color: '#374151' },
      horzLines: { color: '#374151' },
    }
  })

  const candlestickSeries = chart.addCandlestickSeries({
    upColor: '#4caf50',
    downColor: '#f44336',
    borderVisible: false,
    wickVisible: true,
    borderColor: '#4caf50',
    wickColor: '#4caf50',
  })

  candlestickSeries.setData([
    { time: '2023-10-01', open: 80.01, high: 82.04, low: 79.89, close: 81.89 },
    { time: '2023-10-02', open: 81.89, high: 83.04, low: 80.89, close: 82.04 },
    { time: '2023-10-03', open: 82.04, high: 84.04, low: 81.89, close: 83.89 },
    // Добавьте больше данных по необходимости
  ])
})
</script>

<style scoped>
.chart-area {
  width: 100%;
  height: 100%;
}
</style>