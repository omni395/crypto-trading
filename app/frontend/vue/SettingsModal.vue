<template>
  <div id="settings-modal" tabindex="-1" aria-hidden="true"
    class="fixed left-0 right-0 top-0 z-50 h-[calc(100%-1rem)] max-h-full w-full overflow-y-auto overflow-x-hidden p-4 md:inset-0"
    :class="{ hidden: !visible }">
    <div class="relative max-h-full w-full max-w-md mx-auto">
      <div class="relative rounded-lg bg-gray-600 shadow-lg shadow-gray-400">
        <div class="flex items-start justify-between rounded-t border-b border-gray-600 p-5">
          <h3 class="text-xl font-semibold text-white flex items-center gap-2">
            <i class="fa-solid fa-gear text-gray-300 text-2xl"></i>
            Настройки
          </h3>
          <button type="button" class="ms-auto inline-flex h-8 w-8 items-center justify-center rounded-lg bg-transparent text-sm text-gray-400 hover:bg-gray-600 hover:text-white hover:cursor-pointer"
            @click="closeModal">
            <span class="sr-only">Закрыть</span>
            <svg class="h-3 w-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6" />
            </svg>
          </button>
        </div>
        <div class="space-y-4 p-6">
          <form @submit.prevent="saveSettings">
            <div v-if="error" class="text-red-400 text-xs mb-2">{{ error }}</div>
            <div class="mb-4">
              <label for="default_quote_asset" class="block text-xs text-gray-300 mb-1">Котируемая валюта</label>
              <select id="default_quote_asset" v-model="settings.default_quote_asset"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-full">
                <option v-for="qa in quoteAssets" :key="qa" :value="qa">{{ qa.toUpperCase() }}</option>
              </select>
            </div>
            <div class="mb-4">
              <label for="default_status" class="block text-xs text-gray-300 mb-1">Статус</label>
              <select id="default_status" v-model="settings.default_status"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-full">
                <option v-for="st in statuses" :key="st" :value="st">{{ st }}</option>
              </select>
            </div>
            <div class="mb-4">
              <label for="default_exchange" class="block text-xs text-gray-300 mb-1">Биржа</label>
              <select id="default_exchange" v-model="settings.default_exchange"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-full">
                <option v-for="ex in exchanges" :key="ex.name" :value="ex.name">{{ ex.name }}</option>
              </select>
              <div v-if="exchanges.length === 0" class="text-xs text-red-400 mt-2">Нет активных бирж. Добавьте хотя бы одну в админке!</div>
            </div>
            <div class="mb-4">
              <label for="default_volume" class="block text-xs text-gray-300 mb-1">Мин. объем торгов</label>
              <div class="flex gap-2">
                <input type="number" id="default_volume" min="0" placeholder="300000"
                  v-model.number="settings.default_volume"
                  class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-2/3">
                <select v-model="settings.default_volume_currency" class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-1/3">
                  <option value="coin">монет/USD</option>
                </select>
              </div>
            </div>
            <div class="mb-4">
              <label for="default_deals" class="block text-xs text-gray-300 mb-1">Мин. количество сделок</label>
              <input type="number" id="default_deals" min="0" placeholder="100000"
                v-model.number="settings.default_deals"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-full">
            </div>
            <div class="mb-4">
              <label for="default_change" class="block text-xs text-gray-300 mb-1">Изменение за 24ч, %</label>
              <input type="number" id="default_change" step="0.01" placeholder="Любое значение"
                v-model.number="settings.default_change"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-full">
            </div>
            <div class="mb-4">
              <label for="default_price_above" class="block text-xs text-gray-300 mb-1">Цена выше</label>
              <input type="number" id="default_price_above" step="0.01"
                v-model.number="settings.default_price_above"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-1/2 inline-block">
              <label for="default_price_below" class="block text-xs text-gray-300 mb-1 ml-2">Цена ниже</label>
              <input type="number" id="default_price_below" step="0.01"
                v-model.number="settings.default_price_below"
                class="px-2 py-1 rounded bg-gray-800 text-white text-xs w-1/2 inline-block">
            </div>
            <div class="mb-4 flex gap-2">
              <button type="submit" :disabled="loading" class="rounded bg-blue-600 px-4 py-2 text-white text-xs hover:bg-blue-700 transition w-2/3">Сохранить</button>
              <button type="button" @click="resetToDefaults" class="rounded bg-gray-500 px-4 py-2 text-white text-xs hover:bg-gray-600 transition w-1/3">По дефолту</button>
            </div>
            <button v-if="isAdmin" type="button" @click="refreshCoins" class="w-full px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded shadow flex items-center justify-center transition-all mt-4">
              <i class='fa-solid fa-rotate mr-2'></i> Обновить монеты
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useFiltersStore } from '../store/useFiltersStore'
import { useToastrStore } from '../store/useToastrStore'

const store = useFiltersStore()
const toastr = useToastrStore()

// settings теперь реактивная ссылка на store.filters
const settings = store.filters

const loading = ref(false)
const error = ref(null)
const visible = ref(false)
const quoteAssets = ref([])
const statuses = ref([])
const exchanges = ref([])
const isAdmin = ref(false)

function openModal() {
  visible.value = true
}
function closeModal() {
  visible.value = false
}

watch(exchanges, (newExchanges) => {
  if (!settings.default_exchange && newExchanges.length) {
    settings.default_exchange =
      newExchanges.find(ex => ex.name.toLowerCase().includes('spot'))?.name ||
      newExchanges[0].name
  }
})

onMounted(async () => {
  loading.value = true
  try {
    const [settingsRes, dictsRes] = await Promise.all([
      fetch('/api/user_settings'),
      fetch('/api/dictionaries')
    ])
    const userSettings = await settingsRes.json()
    const dicts = await dictsRes.json()
    quoteAssets.value = dicts.quote_assets || []
    statuses.value = dicts.statuses || []
    exchanges.value = dicts.exchanges || []
    isAdmin.value = dicts.is_admin || false

    // Автоматически подставлять значения из базы, если есть, иначе дефолты
    store.setFilters({
      default_quote_asset: userSettings.default_quote_asset || (quoteAssets.value[0] || ''),
      default_status: userSettings.default_status || (statuses.value[0] || ''),
      default_exchange: userSettings.default_exchange || (exchanges.value.find(ex => ex.name.toLowerCase().includes('spot'))?.name || exchanges.value[0]?.name || ''),
      default_volume: userSettings.default_volume ?? 300000,
      default_volume_currency: userSettings.default_volume_currency || 'coin',
      default_deals: userSettings.default_deals ?? 100000,
      default_change: userSettings.default_change ?? 0,
      default_price_above: userSettings.default_price_above ?? 0.01,
      default_price_below: userSettings.default_price_below ?? 5
    })
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
  console.log('exchanges:', exchanges.value)
  console.log('settings.default_exchange:', settings.default_exchange)
})

async function saveSettings() {
  loading.value = true
  error.value = null
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    await fetch('/api/user_settings', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify(settings.value)
    })
    store.setFilters(settings.value)
    closeModal()
    toastr.show('Настройки успешно сохранены!', 'success')
  } catch (e) {
    error.value = e.message
    toastr.show('Ошибка сохранения: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
}

function resetToDefaults() {
  // Можно запросить дефолтные значения с API или сбросить вручную
  store.setFilters({
    default_quote_asset: 'USDT',
    default_status: 'trading',
    default_exchange: exchanges.value.find(ex => ex.name.toLowerCase().includes('spot'))?.name || exchanges.value[0]?.name || '',
    default_volume: 300000,
    default_volume_currency: 'coin',
    default_deals: 100000,
    default_change: 0,
    default_price_above: 0.01,
    default_price_below: 5
  })
}

async function refreshCoins() {
  loading.value = true
  error.value = null
  try {
    await fetch('/api/admin/refresh_binance', { method: 'POST' })
    window.location.reload()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

// Открытие по клику на кнопку в navbar через глобальный event
if (typeof window !== 'undefined') {
  window.openSettingsModal = openModal
  document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('settings-btn')
    if (btn) btn.addEventListener('click', openModal)
  })
}
</script>