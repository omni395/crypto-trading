<template>
  <div class="chart-container" :class="sizeClass">
    <div class="chart-header text-white">
      <h3 class="text-lg font-semibold">{{ title }}</h3>
    </div>
    <div ref="chartRef" class="chart-content"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
import { createChart } from 'lightweight-charts'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  size: {
    type: String,
    default: 'medium', // small, medium, large
    validator: (value) => ['small', 'medium', 'large'].includes(value)
  },
  instrument: {
    type: Object,
    required: true
  }
})

const chartRef = ref(null)
let chart = null

const sizeClass = computed(() => ({
  'h-[200px]': props.size === 'small',
  'h-[300px]': props.size === 'medium',
  'h-[400px]': props.size === 'large'
}))

onMounted(() => {
  initChart()
})

onUnmounted(() => {
  if (chart) {
    chart.remove()
  }
})

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
    }
  })

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