<template>
  <div class="instruments-list flex flex-col h-full min-h-0">
    <div class="container flex flex-col h-full min-h-0">
      <!-- Добавляем индикатор загрузки -->
      <div v-if="loading" class="text-center text-gray-400 py-8">
        <i class="fas fa-spinner fa-spin"></i> Загрузка...
      </div>
      <!-- Показываем ошибку если есть -->
      <div v-else-if="error" class="text-center text-red-400 py-8">
        <i class="fas fa-exclamation-circle"></i> {{ error }}
      </div>
      <!-- Основной контент -->
      <div v-else class="flex flex-col h-full min-h-0">
        <!-- НЕскроллируемая часть -->
        <div class="text-sm text-gray-400 mb-4 shrink-0">
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
        <div class="mb-2 flex justify-center shrink-0">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Поиск монет по списку..."
            class="coin-search__input text-md py-1 px-2 rounded border border-gray-300 focus:border-blue-400 focus:outline-none w-full"
            style="height:32px;"
          />
        </div>
        <div class="sort-section flex justify-between items-center mb-4 mx-4 shrink-0" style="max-width: 500px;">
          <button class="sort-btn" @click="sortBy('alpha')" :class="{ active: sortKey === 'alpha' }" title="По алфавиту">
            <i class="fas fa-sort-alpha-down" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'alpha'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
          </button>
          <button class="sort-btn" @click="sortBy('change')" :class="{ active: sortKey === 'change' }" title="Изменение в %">
            <i class="fas fa-percent" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'change'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
          </button>
          <button class="sort-btn" @click="sortBy('volume')" :class="{ active: sortKey === 'volume' }" title="Объем">
            <i class="fa-solid fa-chart-column" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'volume'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
          </button>
          <button class="sort-btn" @click="sortBy('trades')" :class="{ active: sortKey === 'trades' }" title="Количество сделок">
            <i class="fa-solid fa-money-bill-trend-up" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'trades'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
          </button>
          <button class="sort-btn" @click="sortBy('price')" :class="{ active: sortKey === 'price' }" title="Цена">
            <i class="fas fa-dollar-sign" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'price'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
          </button>
        </div>
        <!-- Скроллируемый список -->
        <div class="flex-1 min-h-0 overflow-y-auto w-full max-w-full overflow-x-hidden custom-scrollbar">
          <Instrument 
            v-for="ins in filteredInstruments" 
            :key="ins.id" 
            :instrument="ins"
            @favorite="toggleFavorite"
            :sortKey="sortKey"
            :selected="selectedInstrument && selectedInstrument.id === ins.id"
            @click="$emit('select-instrument', ins)"
            class="cursor-pointer select-none w-full max-w-full"          />
        </div>
        <!-- Сообщение если нет данных -->
        <div v-if="!instruments.length" class="text-center text-gray-400 py-8">
          Нет монет по выбранным фильтрам
        </div>
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

const exchanges = ref([])

// По умолчанию сортировка по алфавиту вверх
const sortKey = ref('alpha')
const sortAsc = ref(true)
const sortTouched = ref(false) // Был ли пользовательский выбор сортировки

function sortBy(key) {
  if (!sortTouched.value) sortTouched.value = true
  if (sortKey.value === key) {
    sortAsc.value = !sortAsc.value
  } else {
    sortKey.value = key
    sortAsc.value = key === 'alpha' // Для алфавита по умолчанию вверх, для остальных — вниз
  }
  instruments.value.sort((a, b) => {
    let result = 0
    if (key === 'change') result = b.price_change_percent - a.price_change_percent
    if (key === 'volume') result = b.volume - a.volume
    if (key === 'trades') result = b.trades - a.trades
    if (key === 'price') result = b.last_price - a.last_price
    if (key === 'alpha') result = a.symbol.localeCompare(b.symbol)
    return sortAsc.value ? -result : result
  })
}

// Импортируем exchanges из SettingsModal (или грузим отдельно)

// Загружаем фильтры пользователя и exchanges при монтировании
onMounted(async () => {
  await store.loadUserFilters()
  // Загружаем exchanges из /api/dictionaries
  try {
    const dictsRes = await fetch('/api/dictionaries')
    const dicts = await dictsRes.json()
    exchanges.value = dicts.exchanges || []
  } catch (e) {
    error.value = 'Ошибка при загрузке exchanges'
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

const searchQuery = ref('')

const fetchInstruments = async () => {
  try {
    loading.value = true
    error.value = null
    
    const apiFilters = buildApiFilters(store.filters)
    
    const response = await fetch(`/api/dynamics?${new URLSearchParams(apiFilters)}`)
    const data = await response.json()
    
    instruments.value = data
  } catch (e) {
    error.value = 'Ошибка при загрузке данных'
  } finally {
    loading.value = false
  }
}

// computed: фильтрация по base_asset, symbol, name
const filteredInstruments = computed(() => {
  if (!searchQuery.value.trim()) return instruments.value
  const q = searchQuery.value.trim().toLowerCase()
  return instruments.value.filter(ins =>
    (ins.base_asset && ins.base_asset.toLowerCase().includes(q)) ||
    (ins.symbol && ins.symbol.toLowerCase().includes(q)) ||
    (ins.name && ins.name.toLowerCase().includes(q))
  )
})

// Логируем любые изменения фильтров
watch(() => store.filters, (val) => {
}, { deep: true })

watch(() => store.filters, fetchInstruments, { deep: true })
watch(instruments, (newVal) => {
}, { deep: true })

// --- Новый хэндлер для обновления инструментов при изменении фильтров ---
window.addEventListener('filters-updated', async () => {
  await store.loadUserFilters() // подтянуть новые фильтры из API
  await fetchInstruments()
})

// Получаем выбранный инструмент из родителя через пропс
const props = defineProps({
  selectedInstrument: {
    type: Object,
    required: false,
    default: null
  }
})
</script>

<style scoped>
.sort-section {
  margin-bottom: 16px;
}

.sort-btn {
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  background-color: #f7f7f7;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.sort-btn:hover {
  background-color: #e7e7e7;
}

.sort-btn.active {
  background-color: #4CAF50;
  color: #fff;
}

.ml-1 {
  margin-left: 4px;
}
</style>
