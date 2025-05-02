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
let allBars = []

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

async function fetchChartData(exchange, symbol, interval, limit = 200, end_time) {
  console.log('[fetchChartData] params:', { exchange, symbol, interval, limit, end_time })
  if (!exchange || !symbol || !interval) return []
  try {
    const params = { exchange, symbol, interval, limit }
    if (end_time) params.end_time = end_time
    const response = await axios.get('/api/exchange/chart_data', { params })
    console.log('[fetchChartData] response:', response)
    if (response.status !== 200) {
      console.error('Ошибка при получении данных для графика:', response.statusText)
      return []
    }
    const chartData = Array.isArray(response.data) ? response.data : response.data.chart_data
    console.log('[fetchChartData] chartData:', chartData)
    return chartData
  } catch (e) {
    console.error('Ошибка при получении данных для графика:', e)
    return []
  }
}

onMounted(async () => {
  console.log('Lightweight Charts version:', lwcVersion)
  chart = createChart(chartContainer.value, {
    ...chartOptions,
    width: chartContainer.value.clientWidth,
    height: chartContainer.value.clientHeight,
  })

  candlestickSeries = chart.addSeries(CandlestickSeries, seriesOptions)

  const exchange = props.instrument.exchange
  const symbol = props.instrument.symbol
  const interval = '5m'

  // Первая загрузка 200 баров
  console.log('[onMounted] Загружаем первые 200 баров', { exchange, symbol, interval })
  allBars = await fetchChartData(exchange, symbol, interval, 200)
  // Преобразуем time в секунды, если это миллисекунды
  allBars = allBars.map(bar => ({
    ...bar,
    time: bar.time > 9999999999 ? Math.floor(bar.time / 1000) : bar.time
  }))
  // Сортируем по времени
  allBars = allBars.sort((a, b) => a.time - b.time)
  // Удаляем дубликаты по времени
  const seen = new Set()
  allBars = allBars.filter(bar => {
    if (seen.has(bar.time)) return false
    seen.add(bar.time)
    return true
  })
  console.log('[onMounted] allBars:', allBars)
  if (candlestickSeries && allBars) {
    candlestickSeries.setData(allBars)
  }

  let isLoadingHistory = false

  chart.timeScale().subscribeVisibleLogicalRangeChange(async (logicalRange) => {
    if (isLoadingHistory) return
    if (logicalRange.from < 10) {
      // Округляем до целого числа и ограничиваем минимумом 1
      const numberBarsToLoad = Math.max(1, Math.ceil(50 - logicalRange.from))
      if (numberBarsToLoad > 0) {
        isLoadingHistory = true
        const earliestBar = allBars[0]
        const end_time = earliestBar ? earliestBar.time : undefined
        let newBars = await fetchChartData(exchange, symbol, interval, numberBarsToLoad, end_time)
        newBars = newBars.map(bar => ({
          ...bar,
          time: bar.time > 9999999999 ? Math.floor(bar.time / 1000) : bar.time
        }))
        // Фильтруем только те бары, которые действительно старее earliestBar
        newBars = newBars.filter(bar => bar.time < earliestBar.time)
        if (Array.isArray(newBars) && newBars.length > 0) {
          allBars = [...newBars, ...allBars]
          allBars = allBars.sort((a, b) => a.time - b.time)
          const seen = new Set()
          allBars = allBars.filter(bar => {
            if (seen.has(bar.time)) return false
            seen.add(bar.time)
            return true
          })
          candlestickSeries.setData(allBars)
          // Сдвигаем видимую область влево, чтобы пользователь видел новые бары
          chart.timeScale().setVisibleLogicalRange({
            from: logicalRange.from + newBars.length,
            to: logicalRange.to + newBars.length
          })
        }
        isLoadingHistory = false
      }
    }
  })

  window.addEventListener('resize', handleResize)
})

function handleResize() {
  if (chart && chartContainer.value) {
    chart.resize(chartContainer.value.clientWidth, chartContainer.value.clientHeight)
  }
}

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