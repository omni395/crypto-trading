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
          <span>Найдено монет: {{ instruments.length }}</span>
          <span class="ml-2 text-xs">({{ new Date().toLocaleTimeString() }})</span>
          <div v-if="instruments.length > 0" class="mt-2">
            <div class="text-xs">
              Биржа: {{ currentExchangeName }}
            </div>
          </div>
        </div>
        <div class="mb-2 flex justify-center shrink-0">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Поиск по списку..."
            class="coin-search__input text-md py-1 px-2 rounded border border-gray-300 focus:border-blue-400 focus:outline-none w-full"
            style="height:32px;"
          />
        </div>
        <div class="sort-section flex justify-evenly items-center shrink-0" style="max-width: 500px;">
          <button class="sort-btn" @click="sortBy('alpha')" :class="{ active: sortKey === 'alpha' }" title="По алфавиту">
            <i class="fas fa-sort-alpha-down" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'alpha'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
            <span v-else class="arrow-placeholder"></span>
          </button>
          <button class="sort-btn" @click="sortBy('change')" :class="{ active: sortKey === 'change' }" title="Изменение в %">
            <i class="fas fa-percent" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'change'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
            <span v-else class="arrow-placeholder"></span>
          </button>
          <button class="sort-btn" @click="sortBy('volume')" :class="{ active: sortKey === 'volume' }" title="Объем">
            <i class="fa-solid fa-chart-column" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'volume'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
            <span v-else class="arrow-placeholder"></span>
          </button>
          <button class="sort-btn" @click="sortBy('trades')" :class="{ active: sortKey === 'trades' }" title="Количество сделок">
            <i class="fa-solid fa-money-bill-trend-up" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'trades'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
            <span v-else class="arrow-placeholder"></span>
          </button>
          <button class="sort-btn" @click="sortBy('price')" :class="{ active: sortKey === 'price' }" title="Цена">
            <i class="fas fa-dollar-sign" :style="{ color: '#008137' }"></i>
            <span v-if="sortTouched && sortKey === 'price'">
              <i v-if="sortAsc" class="fas fa-arrow-down ml-1 text-yellow-500 drop-shadow font-bold"></i>
              <i v-else class="fas fa-arrow-up ml-1 text-yellow-500 drop-shadow font-bold"></i>
            </span>
            <span v-else class="arrow-placeholder"></span>
          </button>
        </div>
        <!-- Скроллируемый список -->
        <div class="mt-1.5 flex-1 min-h-0 overflow-y-auto w-full max-w-full overflow-x-hidden custom-scrollbar">
          <Instrument 
            v-for="ins in filteredInstruments" 
            :key="ins.id" 
            :instrument="ins"
            :selected="currentSelectedInstrument && currentSelectedInstrument.id === ins.id"
            @click="handleSelectInstrument(ins)"
          />
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
const exchanges = ref([])

// По умолчанию сортировка по алфавиту вверх
const sortKey = ref('alpha')
const sortAsc = ref(true)
const sortTouched = ref(false)

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
    if (data.length > 0 && !currentSelectedInstrument.value) {
      handleSelectInstrument(data[0])
    }
  } catch (e) {
    error.value = 'Ошибка при загрузке данных'
  } finally {
    loading.value = false
  }
}

const filteredInstruments = computed(() => {
  if (!searchQuery.value.trim()) return instruments.value
  const q = searchQuery.value.trim().toLowerCase()
  return instruments.value.filter(ins =>
    (ins.base_asset && ins.base_asset.toLowerCase().includes(q)) ||
    (ins.symbol && ins.symbol.toLowerCase().includes(q)) ||
    (ins.name && ins.name.toLowerCase().includes(q))
  )
})

// Убираем пустые watch
watch(() => store.filters, fetchInstruments, { deep: true })

window.addEventListener('filters-updated', async () => {
  await store.loadUserFilters()
  await fetchInstruments()
})

const props = defineProps({
  selectedInstrument: {
    type: Object,
    required: false,
    default: null
  }
})

const emit = defineEmits(['select-instrument'])

const currentSelectedInstrument = ref(null)

function handleSelectInstrument(ins) {
  currentSelectedInstrument.value = ins
  emit('select-instrument', ins)
}
</script>

<style scoped>
.sort-section {
  margin-bottom: 8px;
  width: 100%;
  min-width: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: nowrap;
}

.sort-btn {
  padding: 2px 4px;
  margin: 2px;
  border: none;
  border-radius: 4px;
  background-color: #364153;
  cursor: pointer;
  display: flex;
  align-items: center;
  min-width: 28px;
  justify-content: center;
  position: relative;
  height: 28px; /* уменьшенная высота */
  box-sizing: border-box;
  font-size: 14px;
}

.arrow-placeholder,
.sort-btn .ml-1,
.sort-btn .fa-arrow-down,
.sort-btn .fa-arrow-up {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 12px;  /* уменьшенная ширина */
  height: 12px; /* уменьшенная высота */
  margin-left: 1px;
  font-size: 12px;
  line-height: 1;
}

.sort-btn:hover {
  color: #4CAF50;
}

.sort-btn:hover i {
  filter: brightness(1.5);
  /* или, если хотите изменить цвет, например: */
  /* color: #6ee7b7 !important; */
}

.sort-btn.active {
  background-color: #364153;
}

.ml-1 {
  margin-left: 1px;
}
</style>
