<template>
  <div class="chart-area h-[380px]">
    <v-chart
      :option="option"
      :autoresize="true"
      style="width: 100%; height: 100%"
      @ready="onChartReady"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { use } from 'echarts/core'
import VChart from 'vue-echarts'
import { CanvasRenderer } from 'echarts/renderers'
import { CandlestickChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, TitleComponent, DataZoomComponent, LegendComponent } from 'echarts/components'
import axios from 'axios'
 
use([
  CanvasRenderer,
  CandlestickChart,
  GridComponent,
  TooltipComponent,
  TitleComponent,
  DataZoomComponent,
  LegendComponent
])

const props = defineProps({
  instrument: Object
})

const option = ref({
  title: { text: '', left: 'center', textStyle: { color: '#d1d5db' } },
  backgroundColor: '#1f2937',
  tooltip: { trigger: 'axis' },
  legend: { data: ['Candlestick'], textStyle: { color: '#d1d5db' } },
  grid: { left: '5%', right: '5%', bottom: '10%', top: '10%' },
  xAxis: {
    type: 'category',
    data: [],
    scale: true,
    boundaryGap: true,
    axisLine: { lineStyle: { color: '#374151' } },
    axisLabel: { color: '#d1d5db' }
  },
  yAxis: {
    scale: true,
    axisLine: { lineStyle: { color: '#374151' } },
    splitLine: { lineStyle: { color: '#374151' } },
    axisLabel: { color: '#d1d5db' }
  },
  dataZoom: [
    { type: 'inside', start: 50, end: 100 },
    { show: true, type: 'slider', bottom: 0, start: 50, end: 100 }
  ],
  series: [
    {
      name: 'Candlestick',
      type: 'candlestick',
      data: []
    }
  ]
})

const bars = ref([]) // Храним все загруженные бары
const isLoading = ref(false)
const oldestTime = ref(null) // Для отслеживания самого старого времени

async function fetchChartData(exchange, symbol, interval, limit = 200, end_time) {
  console.log('[fetchChartData] params:', { exchange, symbol, interval, limit, end_time })
  if (!exchange || !symbol || !interval) {
    console.warn('[fetchChartData] Не переданы exchange, symbol или interval')
    return []
  }
  try {
    const params = { exchange, symbol, interval, limit }
    if (end_time) params.end_time = end_time
    console.log('[fetchChartData] Request URL:', '/api/exchange/chart_data')
    console.log('[fetchChartData] Request params:', params)
    
    const response = await axios.get('/api/exchange/chart_data', { params })
    console.log('[fetchChartData] Full response:', response)
    console.log('[fetchChartData] Response status:', response.status)
    console.log('[fetchChartData] Response headers:', response.headers)
    console.log('[fetchChartData] Raw response data:', response.data)
    
    if (response.status !== 200) {
      console.error('[fetchChartData] Ошибка при получении данных для графика:', response.statusText)
      return []
    }
    
    const chartData = Array.isArray(response.data) ? response.data : response.data.chart_data
    console.log('[fetchChartData] Processed chartData:', chartData)
    console.log('[fetchChartData] chartData type:', typeof chartData)
    console.log('[fetchChartData] chartData length:', chartData.length)
    
    return chartData
  } catch (e) {
    console.error('[fetchChartData] Ошибка при получении данных для графика:', e)
    console.error('[fetchChartData] Error details:', {
      message: e.message,
      response: e.response,
      request: e.request
    })
    return []
  }
}

function formatToEcharts(data) {
  console.log('[formatToEcharts] Входные данные:', data)
  const categoryData = []
  const values = []
  data.forEach(bar => {
    const date = new Date(bar.time * 1000)
    categoryData.push(
      `${date.getFullYear()}-${(date.getMonth()+1).toString().padStart(2,'0')}-${date.getDate().toString().padStart(2,'0')} ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}`
    )
    values.push([bar.open, bar.close, bar.low, bar.high])
  })
  console.log('[formatToEcharts] categoryData:', categoryData)
  console.log('[formatToEcharts] values:', values)
  return { categoryData, values }
}

async function loadChart(initial = false) {
  if (isLoading.value) return
  isLoading.value = true
  const exchange = props.instrument.exchange
  const symbol = props.instrument.symbol
  const interval = '5m'
  let end_time = undefined
  if (!initial && oldestTime.value) {
    end_time = oldestTime.value
  }
  let newBars = await fetchChartData(exchange, symbol, interval, 200, end_time)
  console.log('[loadChart] Получено баров:', newBars.length)
  newBars = newBars.map(bar => ({
    ...bar,
    time: bar.time > 9999999999 ? Math.floor(bar.time / 1000) : bar.time
  }))
  newBars = newBars.sort((a, b) => a.time - b.time)
  if (initial) {
    bars.value = newBars
  } else {
    bars.value = [...newBars, ...bars.value]
  }
  if (bars.value.length > 0) {
    oldestTime.value = bars.value[0].time
  }
  const { categoryData, values } = formatToEcharts(bars.value)
  console.log('[loadChart] categoryData.length:', categoryData.length)
  console.log('[loadChart] values.length:', values.length)
  option.value = {
    ...option.value,
    xAxis: { ...option.value.xAxis, data: categoryData },
    series: [{ ...option.value.series[0], data: values }]
  }
  isLoading.value = false
}

function onDataZoom(params) {
  // Если пользователь приблизился к левому краю, подгружаем еще свечи
  if (params.batch && params.batch.length > 0) {
    const start = params.batch[0].start
    console.log('[onDataZoom] start:', start)
    if (start <= 2 && !isLoading.value) {
      console.log('[onDataZoom] Загружаем дополнительные свечи...')
      loadChart(false)
    }
  }
}

onMounted(() => {
  loadChart(true)
})

watch(() => props.instrument, () => loadChart(true), { deep: true })

// Подписка на событие dataZoom
function onChartReady(chartInstance) {
  chartInstance.on('dataZoom', onDataZoom)
}
</script>

<style scoped>
.chart-area {
  width: 100%;
  height: 100%;
}
</style>