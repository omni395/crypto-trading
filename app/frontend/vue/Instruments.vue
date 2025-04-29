<template>
  <div class="container">
    <!-- Добавляем индикатор загрузки -->
    <div v-if="loading" class="text-center text-gray-400 py-8">
      <i class="fas fa-spinner fa-spin"></i> Загрузка...
    </div>
    
    <!-- Показываем ошибку если есть -->
    <div v-else-if="error" class="text-center text-red-400 py-8">
      <i class="fas fa-exclamation-circle"></i> {{ error }}
    </div>
    
    <!-- Основной контент -->
    <div v-else>
      <!-- Статистика -->
      <div class="text-sm text-gray-400 mb-4">
        Найдено монет: {{ instruments.length }}
        <div v-if="instruments.length > 0" class="mt-2">
          <div class="text-xs">
            Последнее обновление: {{ new Date().toLocaleTimeString() }}
          </div>
          <div class="text-xs">
            Биржа: {{ currentExchangeName }}
          </div>
        </div>
      </div>
            
      <!-- Список инструментов -->
      <div class="space-y-2">
        <Instrument 
          v-for="ins in instruments" 
          :key="ins.id" 
          :instrument="ins"
          @favorite="toggleFavorite"
        />
      </div>
      
      <!-- Сообщение если нет данных -->
      <div v-if="!instruments.length" class="text-center text-gray-400 py-8">
        Нет монет по выбранным фильтрам
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useFiltersStore } from '../store/useFiltersStore'
import Instrument from './Instrument.vue'

const store = useFiltersStore()
const loading = ref(false)
const error = ref(null)
const instruments = ref([])
const debug = ref(true) // Включаем режим отладки по умолчанию

// Импортируем exchanges из SettingsModal (или грузим отдельно)
const exchanges = ref([])

// Загружаем фильтры пользователя и exchanges при монтировании
onMounted(async () => {
  await store.loadUserFilters()
  // Загружаем exchanges из /api/dictionaries
  try {
    const dictsRes = await fetch('/api/dictionaries')
    const dicts = await dictsRes.json()
    exchanges.value = dicts.exchanges || []
  } catch (e) {
    console.warn('[Instruments] Не удалось загрузить exchanges:', e)
    exchanges.value = []
  }
  fetchInstruments()
})

// Вычисляем имя биржи по slug из первого инструмента
const currentExchangeName = computed(() => {
  if (!instruments.value.length) return 'Не указана'
  const slug = instruments.value[0]?.exchange
  const found = exchanges.value.find(ex => ex.slug === slug)
  return found?.name || slug || 'Не указана'
})

// Улучшенная функция построения фильтров
function buildApiFilters(settings) {
  const filters = {
    quote_asset: settings.default_quote_asset,
    status: settings.default_status,
    exchange: settings.default_exchange,
    min_volume: settings.default_volume,
    min_deals: settings.default_deals,
    min_price: settings.default_price_above,
    max_price: settings.default_price_below,
    min_change: settings.default_change
  }
  
  // Удаляем пустые значения
  return Object.fromEntries(
    Object.entries(filters).filter(([_, v]) => v != null && v !== '')
  )
}

// Добавляем обработку избранного
async function toggleFavorite(instrumentId) {
  try {
    const method = instrument.isFavorite ? 'DELETE' : 'POST'
    await fetch(`/api/favorites/${instrumentId}`, { 
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    await fetchInstruments() // Обновляем список
  } catch (e) {
    error.value = 'Ошибка при обновлении избранного'
  }
}

const fetchInstruments = async () => {
  try {
    loading.value = true
    error.value = null
    
    console.log('[Instruments] Начало запроса данных')
    const apiFilters = buildApiFilters(store.filters)
    console.log('[Instruments] Подготовленные фильтры:', apiFilters)
    
    const response = await fetch(`/api/dynamics?${new URLSearchParams(apiFilters)}`)
    const data = await response.json()
    
    console.log('[Instruments] Ответ от сервера:', {
      status: response.status,
      ok: response.ok,
      data: data
    })
    
    instruments.value = data
    
    console.log('[Instruments] Данные после обработки:', {
      total: instruments.value.length,
      sample: instruments.value.slice(0, 3)
    })
  } catch (e) {
    console.error('[Instruments] Ошибка при загрузке:', e)
    error.value = 'Ошибка при загрузке данных'
  } finally {
    loading.value = false
  }
}

// Логируем любые изменения фильтров
watch(() => store.filters, (val) => {
  console.log('[Instruments] Изменились фильтры:', val)
}, { deep: true })

watch(() => store.filters, fetchInstruments, { deep: true })
watch(instruments, (newVal) => {
  console.log('[Instruments] Обновление данных:', {
    total: newVal.length,
    data: newVal.map(i => ({
      symbol: i.symbol,
      price: i.last_price,
      volume: i.volume,
      change: i.price_change_percent
    }))
  })
}, { deep: true })
</script>

<style scoped>
/**** Можно добавить стили для списка ****/
</style>
