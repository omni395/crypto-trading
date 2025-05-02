<template>
  <div class="chart-area h-[380px]" ref="chartContainer"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { createChart, version as lwcVersion, CandlestickSeries } from 'lightweight-charts'
import axios from 'axios'

const props = defineProps({
  instrument: Object
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
  const exchange = props.instrument.exchange
  const symbol = props.instrument.symbol
  const interval = '5m'
  console.log('Instrument:', symbol)
  console.log('Chart URL:', props.instrument?.raw.crypto.exchange.chart_url)
  console.log('interval:', interval)
  try {
    console.log('chart_data params:', { exchange, symbol, interval });
    const response = await axios.get('/api/exchange/chart_data', { params: { exchange, symbol, interval } })
    console.log('chart_data response:', response)
    if (response.status !== 200) {
      console.error('Ошибка при получении данных для графика:', response.statusText)
      return
    }
    console.log('Полученные данные для графика:', response.data)
    // Вот здесь добавьте универсальную обработку:
    const chartData = Array.isArray(response.data) ? response.data : response.data.chart_data
    if (candlestickSeries) {
      candlestickSeries.setData(chartData)
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
  console.log('Lightweight Charts version:', lwcVersion)
  chart = createChart(chartContainer.value, {
    ...chartOptions,
    width: chartContainer.value.clientWidth,
    height: chartContainer.value.clientHeight,
  })

  candlestickSeries = chart.addSeries(CandlestickSeries, seriesOptions)
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