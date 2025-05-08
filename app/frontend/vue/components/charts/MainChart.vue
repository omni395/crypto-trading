<template>
  <div class="chart-area h-[380px]">
    <v-chart
      :option="option"
      :autoresize="true"
      style="width: 100%; height: 100%"
      @datazoom="onDataZoom"
      @click="onChartClick"
      @mousewheel="onMouseWheel"
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

const bars = ref([])
const isLoading = ref(false)
const oldestTime = ref(null)
const MAX_BARS = 10000

const onEvents = {
  datazoom: (params) => {
    console.log('[Template Event] datazoom:', params)
  },
  mousewheel: (params) => {
    console.log('[Template Event] mousewheel:', params)
  },
  click: (params) => {
    console.log('[Template Event] click:', params)
  }
}

async function fetchChartData(exchange, symbol, interval, limit = 500, end_time) {
  if (!exchange || !symbol || !interval) {
    console.warn('[fetchChartData] Не переданы exchange, symbol или interval')
    return []
  }
  try {
    const params = { exchange, symbol, interval, limit }
    if (end_time) {
      // Используем start_time вместо end_time для получения более старых данных
      // Вычитаем 5 минут * 500 баров (примерно 41.5 часов) для получения более старых данных
      const start_time = (end_time - (300 * 500)) * 1000
      params.start_time = start_time
      params.end_time = end_time * 1000
      console.log(`[fetchChartData] Запрашиваем данные с ${new Date(start_time).toISOString()} по ${new Date(params.end_time).toISOString()}`)
      console.log(`[fetchChartData] Параметры времени: start_time=${start_time}, end_time=${params.end_time}`)
    }
    
    console.log('[fetchChartData] Параметры запроса:', params)
    const response = await axios.get('/api/exchange/chart_data', { params })
    
    if (response.status !== 200) {
      console.error('[fetchChartData] Ошибка при получении данных для графика:', response.statusText)
      return []
    }
    
    const chartData = Array.isArray(response.data) ? response.data : response.data.chart_data
    
    // Проверяем и исправляем времена баров
    const validData = chartData.map(bar => {
      let time = bar.time
      // Если время в миллисекундах, конвертируем в секунды
      if (time > 9999999999) {
        time = Math.floor(time / 1000)
      }
      // Проверяем, что время находится в разумных пределах (не раньше 2000 года и не позже 2100)
      const date = new Date(time * 1000)
      if (date.getFullYear() < 2000 || date.getFullYear() > 2100) {
        console.warn(`[fetchChartData] Некорректное время бара: ${date.toISOString()}, пропускаем`)
        return null
      }
      return { ...bar, time }
    }).filter(bar => bar !== null)
    
    if (validData.length > 0) {
      const firstBar = validData[0]
      const lastBar = validData[validData.length - 1]
      console.log(`[fetchChartData] Получены данные с ${new Date(firstBar.time * 1000).toISOString()} по ${new Date(lastBar.time * 1000).toISOString()}`)
      console.log(`[fetchChartData] Количество полученных баров: ${validData.length}`)
    }
    return validData
  } catch (e) {
    console.error('[fetchChartData] Ошибка при получении данных для графика:', e)
    return []
  }
}

function formatToEcharts(data) {
  const categoryData = []
  const values = []
  data.forEach(bar => {
    const date = new Date(bar.time * 1000)
    categoryData.push(
      `${date.getFullYear()}-${(date.getMonth()+1).toString().padStart(2,'0')}-${date.getDate().toString().padStart(2,'0')} ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}`
    )
    values.push([bar.open, bar.close, bar.low, bar.high])
  })
  return { categoryData, values }
}

async function loadChart(initial = false) {
  if (isLoading.value) return
  isLoading.value = true
  
  const exchange = props.instrument.exchange
  const symbol = props.instrument.symbol
  const interval = '5m'
  let end_time = undefined
  
  if (!initial && bars.value.length > 0) {
    // Берем время самого старого бара для загрузки более старых данных
    end_time = bars.value[0].time
    console.log(`[loadChart] Текущий самый старый бар: ${new Date(end_time * 1000).toISOString()}`)
  }
  
  let newBars = await fetchChartData(exchange, symbol, interval, 500, end_time)
  
  if (newBars.length === 0) {
    console.log('[loadChart] Нет новых данных для загрузки')
    isLoading.value = false
    return
  }

  // Сортируем по времени
  newBars.sort((a, b) => a.time - b.time)
  
  // Проверяем, что новые данные действительно старше текущих
  if (!initial && newBars.length > 0) {
    const oldestNewBar = newBars[0].time
    const oldestCurrentBar = bars.value[0].time
    console.log(`[loadChart] Сравнение: новый самый старый бар ${new Date(oldestNewBar * 1000).toISOString()}, текущий самый старый бар ${new Date(oldestCurrentBar * 1000).toISOString()}`)
    
    // Проверяем, что новый самый старый бар действительно старше текущего
    if (oldestNewBar >= oldestCurrentBar) {
      console.log('[loadChart] Получены не более старые данные, прекращаем загрузку')
      isLoading.value = false
      return
    }
    
    // Проверяем, что нет дубликатов
    const existingTimes = new Set(bars.value.map(bar => bar.time))
    newBars = newBars.filter(bar => !existingTimes.has(bar.time))
    
    if (newBars.length === 0) {
      console.log('[loadChart] Все полученные бары уже существуют в текущем наборе')
      isLoading.value = false
      return
    }
  }
  
  if (initial) {
    bars.value = newBars
  } else {
    // Объединяем старые и новые бары
    const allBars = [...newBars, ...bars.value]
    // Сортируем по времени
    allBars.sort((a, b) => a.time - b.time)
    
    // Проверяем ограничение
    if (allBars.length > MAX_BARS) {
      console.log(`[loadChart] Достигнут лимит в ${MAX_BARS} баров. Обрезаем до последних ${MAX_BARS} баров.`)
      bars.value = allBars.slice(-MAX_BARS)
    } else {
      bars.value = allBars
    }
  }
  
  if (bars.value.length > 0) {
    oldestTime.value = bars.value[0].time
  }
  
  const { categoryData, values } = formatToEcharts(bars.value)
  console.log(`[loadChart] Загружено новых баров: ${newBars.length}, всего баров: ${categoryData.length}`)
  
  // Обновляем график с сохранением текущего масштаба
  const currentOption = option.value
  const currentZoom = currentOption.dataZoom[0]
  
  option.value = {
    ...currentOption,
    xAxis: { ...currentOption.xAxis, data: categoryData },
    series: [{ ...currentOption.series[0], data: values }],
    dataZoom: [
      { 
        ...currentZoom,
        start: currentZoom.start,
        end: currentZoom.end
      },
      { 
        ...currentOption.dataZoom[1],
        start: currentOption.dataZoom[1].start,
        end: currentOption.dataZoom[1].end
      }
    ]
  }
  
  isLoading.value = false
}

function onDataZoom(params) {
  if (params.batch && params.batch.length > 0) {
    const start = params.batch[0].start
    if (start <= 20 && !isLoading.value && bars.value.length < MAX_BARS) {
      console.log('Загрузка дополнительных данных...')
      loadChart(false)
    } else if (bars.value.length >= MAX_BARS) {
      console.log(`Достигнут лимит в ${MAX_BARS} баров. Дальнейшая загрузка остановлена.`)
    }
  }
}

function onChartClick(params) {
  console.log('[Chart Click]', params)
}

function onMouseWheel(params) {
  console.log('[Chart MouseWheel]', params)
}

onMounted(() => {
  console.log('[onMounted] Инициализация компонента')
  loadChart(true)
})

watch(() => props.instrument, () => {
  console.log('[watch] Изменен инструмент, перезагружаем график')
  loadChart(true)
}, { deep: true })

function onChartReady(instance) {
  console.log('[onChartReady] Инициализация графика')
  
  // Добавляем обработчики через instance
  instance.on('datazoom', (params) => {
    console.log('[Instance Event] datazoom:', params)
  })
  
  instance.on('mousewheel', (params) => {
    console.log('[Instance Event] mousewheel:', params)
  })
  
  instance.on('click', (params) => {
    console.log('[Instance Event] click:', params)
  })
}
</script>

<style scoped>
.chart-area {
  width: 100%;
  height: 100%;
}
</style>