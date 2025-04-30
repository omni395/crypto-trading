<template>
  <div class="chart-container" :class="sizeClass">
    <div class="chart-header text-white">
      <h3 class="text-lg font-semibold">{{ title }}</h3>
    </div>
    <div ref="chartRef" class="chart-content"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted, computed } from 'vue'
import { createChart } from 'lightweight-charts'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  size: {
    type: String,
    default: 'medium',
    validator: (value) => ['small', 'medium', 'large'].includes(value)
  },
  instrument: {
    type: Object,
    required: true
  }
})

const chartRef = ref(null)
let chart = null
let candleSeries = null
let volumeSeries = null

const sizeClass = computed(() => ({
  'h-[200px]': props.size === 'small',
  'h-[300px]': props.size === 'medium',
  'h-[400px]': props.size === 'large'
}))

const initChart = () => {
  if (!chartRef.value) return

  chart = createChart(chartRef.value, {
    width: chartRef.value.clientWidth,
    height: chartRef.value.clientHeight,
    layout: {
      background: { color: '#1f2937' },
      textColor: '#d1d5db',
    },
    grid: {
      vertLines: { color: '#374151' },
      horzLines: { color: '#374151' },
    },
    crosshair: {
      mode: 1,
      vertLine: {
        color: '#6b7280',
        width: 1,
        style: 2,
      },
      horzLine: {
        color: '#6b7280',
        width: 1,
        style: 2,
      },
    }
  })

  // Создаем серию для свечей
  candleSeries = chart.addCandlestickSeries({
    upColor: '#22c55e',
    downColor: '#ef4444',
    borderUpColor: '#22c55e',
    borderDownColor: '#ef4444',
    wickUpColor: '#22c55e',
    wickDownColor: '#ef4444',
  })

  // Создаем серию для объемов
  volumeSeries = chart.addHistogramSeries({
    color: '#60a5fa',
    priceFormat: {
      type: 'volume',
    },
    priceScaleId: '', // Отдельная ценовая шкала
    scaleMargins: {
      top: 0.8, // Отступ сверху
      bottom: 0,
    },
  })

  // Обработчик изменения размера
  const handleResize = () => {
    if (chart && chartRef.value) {
      chart.applyOptions({
        width: chartRef.value.clientWidth,
        height: chartRef.value.clientHeight
      })
    }
  }

  window.addEventListener('resize', handleResize)
  onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
  })
}

// Функция для обновления данных графика
const updateChartData = (data) => {
  if (!candleSeries || !volumeSeries) return

  // Предполагаем, что data содержит массив с объектами вида:
  // { time: '2023-12-01', open: 100, high: 105, low: 95, close: 102, volume: 1000 }
  const candleData = data.map(item => ({
    time: item.time,
    open: item.open,
    high: item.high,
    low: item.low,
    close: item.close
  }))

  const volumeData = data.map(item => ({
    time: item.time,
    value: item.volume,
    color: item.close >= item.open ? '#22c55e' : '#ef4444'
  }))

  candleSeries.setData(candleData)
  volumeSeries.setData(volumeData)
}

onMounted(() => {
  initChart()
})

onUnmounted(() => {
  if (chart) {
    chart.remove()
    chart = null
  }
})

// Следим за изменением инструмента
watch(() => props.instrument, (newInstrument) => {
  if (newInstrument) {
    // Здесь будем загружать данные для нового инструмента
    // Пока используем тестовые данные
    const testData = [
      { time: '2023-12-01', open: 100, high: 105, low: 95, close: 102, volume: 1000 },
      { time: '2023-12-02', open: 102, high: 108, low: 100, close: 105, volume: 1500 },
      // ... добавьте больше тестовых данных
    ]
    updateChartData(testData)
  }
}, { immediate: true })
</script>

<style scoped>
.chart-container {
  @apply bg-gray-800 rounded-lg p-4 w-full;
}

.chart-header {
  @apply mb-2;
}

.chart-content {
  @apply w-full h-full;
}
</style>