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
      @legendselectchanged="onLegendSelectChanged"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
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

const eyeOpenPath = 'path://M288 80c-65.2 0-118.8 29.6-159.9 67.7C89.6 183.5 63 226 49.4 256c13.6 30 40.2 72.5 78.6 108.3C169.2 402.4 222.8 432 288 432s118.8-29.6 159.9-67.7C486.4 328.5 513 286 526.6 256c-13.6-30-40.2-72.5-78.6-108.3C406.8 109.6 353.2 80 288 80zM95.4 112.6C142.5 68.8 207.2 32 288 32s145.5 36.8 192.6 80.6c46.8 43.5 78.1 95.4 93 131.1c3.3 7.9 3.3 16.7 0 24.6c-14.9 35.7-46.2 87.7-93 131.1C433.5 443.2 368.8 480 288 480s-145.5-36.8-192.6-80.6C48.6 356 17.3 304 2.5 268.3c-3.3-7.9-3.3-16.7 0-24.6C17.3 208 48.6 156 95.4 112.6zM288 336c44.2 0 80-35.8 80-80s-35.8-80-80-80c-.7 0-1.3 0-2 0c1.3 5.1 2 10.5 2 16c0 35.3-28.7 64-64 64c-5.5 0-10.9-.7-16-2c0 .7 0 1.3 0 2c0 44.2 35.8 80 80 80zm0-208a128 128 0 1 1 0 256 128 128 0 1 1 0-256z';
const eyeClosedPath = 'path://M38.8 5.1C28.4-3.1 13.3-1.2 5.1 9.2S-1.2 34.7 9.2 42.9l592 464c10.4 8.2 25.5 6.3 33.7-4.1s6.3-25.5-4.1-33.7L525.6 386.7c39.6-40.6 66.4-86.1 79.9-118.4c3.3-7.9 3.3-16.7 0-24.6c-14.9-35.7-46.2-87.7-93-131.1C465.5 68.8 400.8 32 320 32c-68.2 0-125 26.3-169.3 60.8L38.8 5.1zm151 118.3C226 97.7 269.5 80 320 80c65.2 0 118.8 29.6 159.9 67.7C518.4 183.5 545 226 558.6 256c-12.6 28-36.6 66.8-70.9 100.9l-53.8-42.2c9.1-17.6 14.2-37.5 14.2-58.7c0-70.7-57.3-128-128-128c-32.2 0-61.7 11.9-84.2 31.5l-46.1-36.1zM394.9 284.2l-81.5-63.9c4.2-8.5 6.6-18.2 6.6-28.3c0-5.5-.7-10.9-2-16c.7 0 1.3 0 2 0c44.2 0 80 35.8 80 80c0 9.9-1.8 19.4-5.1 28.2zm9.4 130.3C378.8 425.4 350.7 432 320 432c-65.2 0-118.8-29.6-159.9-67.7C121.6 328.5 95 286 81.4 256c8.3-18.4 21.5-41.5 39.4-64.8L83.1 161.5C60.3 191.2 44 220.8 34.5 243.7c-3.3 7.9-3.3 16.7 0 24.6c14.9 35.7 46.2 87.7 93 131.1C174.5 443.2 239.2 480 320 480c47.8 0 89.9-12.9 126.2-32.5l-41.9-33zM192 256c0 70.7 57.3 128 128 128c13.3 0 26.1-2 38.2-5.8L302 334c-23.5-5.4-43.1-21.2-53.7-42.3l-56.1-44.2c-.2 2.8-.3 5.6-.3 8.5z';

const selected = ref({});

const getLegendIcon = computed(() => {
  // Имя серии (монета)
  const symbol = props.instrument?.symbol || '';
  // Если серия выбрана — открытый глаз, иначе перечёркнутый
  return selected.value[symbol] !== false ? eyeOpenPath : eyeClosedPath;
});

const option = ref({
  title: { 
    text: `${props.instrument?.symbol || ''} - ${props.instrument?.exchange_name || ''}`,
    left: '3%',
    top: '3%',
    textStyle: { 
      color: '#d1d5db',
      fontSize: 16,
      fontWeight: 'bold'
    } 
  },
  backgroundColor: '#1f2937',
  tooltip: { trigger: 'axis' },
  legend: {
    data: [`${props.instrument?.symbol || ''}`],
    textStyle: { color: '#d1d5db' },
    left: '3%',
    top: '10%',
    icon: getLegendIcon.value,
    itemWidth: 18,
    itemHeight: 12,
    backgroundColor: 'rgba(31,41,55,0.7)',
    borderRadius: 4,
    selected: selected.value
  },
  grid: { 
    left: '3%',
    right: '3%',
    bottom: '10%',
    top: '15%',
    containLabel: true
  },
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
    position: 'right',
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
      name: `${props.instrument?.symbol || ''}`,
      type: 'candlestick',
      data: [],
      itemStyle: {
        color: '#26a69a',  // Зеленый цвет для бычьих свечей (когда close > open)
        color0: '#ef5350', // Красный цвет для медвежьих свечей (когда close < open)
        borderColor: '#26a69a',
        borderColor0: '#ef5350'
      }
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
    title: {
      text: `${props.instrument?.symbol || ''} - ${props.instrument?.exchange_name || ''}`,
      left: '3%',
      top: '3%',
      textStyle: {
        color: '#d1d5db',
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    legend: {
      data: [`${props.instrument?.symbol || ''}`],
      textStyle: { color: '#d1d5db' },
      left: '3%',
      top: '10%',
      icon: getLegendIcon.value,
      itemWidth: 18,
      itemHeight: 12,
      backgroundColor: 'rgba(31,41,55,0.7)',
      borderRadius: 4,
      selected: selected.value
    },
    xAxis: { ...currentOption.xAxis, data: categoryData },
    series: [{ ...currentOption.series[0], name: `${props.instrument?.symbol || ''}`, data: values }],
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

function onLegendSelectChanged(params) {
  selected.value = { ...params.selected };
  // Обновляем icon и selected
  option.value.legend.icon = getLegendIcon.value;
  option.value.legend.selected = selected.value;
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