<template>
  <div class="chart-area h-[380px]" ref="chartContainer"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { createChart } from 'lightweight-charts'
import axios from 'axios'

const props = defineProps({
  instrument: { type: Object, required: true },
  chartUrl: { type: String, required: true }
})

const chartContainer = ref(null)
let chart = null
let candlestickSeries = null

const chartOptions = {
  layout: {
    background: { color: '#1f2937' },
    textColor: '#d1d5db',
  },
  grid: {
    vertLines: { color: '#374151' },
    horzLines: { color: '#374151' },
  },
  timeScale: {
    rightOffset: 1,
    barSpacing: 5,
    borderVisible: false,
  }
}

const seriesOptions = {
  upColor: '#4caf50',
  downColor: '#f44336',
  borderVisible: false,
  wickVisible: true,
  borderColor: '#4caf50',
  wickColor: '#4caf50',
}

async function fetchChartData() {
  if (!props.instrument || !props.instrument.symbol) return
  const symbol = props.instrument.symbol
  const interval = '5m'
  const url = props.chartUrl.replace('%{symbol}', encodeURIComponent(symbol)) + `&interval=${interval}&limit=200`
  try {
    const response = await axios.get(url)
    if (candlestickSeries) {
      candlestickSeries.setData(response.data)
    }
  } catch (e) {
    console.error('Ошибка при получении данных для графика:', e)
  }
}

function handleResize() {
  if (chart && chartContainer.value) {
    chart.resize(chartContainer.value.clientWidth, chartContainer.value.clientHeight)
  }
}

onMounted(() => {
  chart = createChart(chartContainer.value, {
    ...chartOptions,
    width: chartContainer.value.clientWidth,
    height: chartContainer.value.clientHeight,
  })

  console.log('Chart instance:', chart)
  console.log('ChartContainer:', chartContainer.value)
  if (typeof chart.addCandlestickSeries !== 'function') {
    console.error('addCandlestickSeries is not a function on chart:', chart)
  }

  candlestickSeries = chart.addSeries('candlestick', seriesOptions)

  fetchChartData()

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (chart) {
    chart.remove()
    chart = null
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.chart-area {
  width: 100%;
  height: 100%;
}
</style>