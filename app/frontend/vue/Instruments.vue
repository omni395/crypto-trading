<template>
  <div>
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
import { ref, onMounted, watch } from 'vue'
import { useFiltersStore } from '../store/useFiltersStore'
import Instrument from './Instrument.vue'

const store = useFiltersStore()
const loading = ref(false)
const error = ref(null)
const instruments = ref([])

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

async function fetchInstruments() {
  if (!store?.filters) {
    console.error('Store filters not initialized')
    return
  }
  
  loading.value = true
  error.value = null
  try {
    const apiFilters = buildApiFilters(store.filters)
    const params = new URLSearchParams(apiFilters).toString()
    const res = await fetch(`/api/dynamics?${params}`)
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`)
    }
    const data = await res.json()
    if (data.error) {
      throw new Error(data.error)
    }
    instruments.value = data.instruments || []
  } catch (e) {
    error.value = `Ошибка при загрузке данных: ${e.message}`
    console.error('Error fetching instruments:', e)
  } finally {
    loading.value = false
  }
}

onMounted(fetchInstruments)
watch(() => store.filters, fetchInstruments, { deep: true })
</script>

<style scoped>
/**** Можно добавить стили для списка ****/
</style>
