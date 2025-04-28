<template>
  <div>
    <div v-if="loading" class="text-center text-gray-400 py-8">Загрузка...</div>
    <div v-else-if="error" class="text-center text-red-400 py-8">Ошибка: {{ error }}</div>
    <div v-else>
      <Instrument v-for="ins in instruments" :key="ins.id" :instrument="ins" />
      <div v-if="!instruments.length" class="text-center text-gray-400 py-8">Нет монет по выбранным фильтрам</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useFiltersStore } from '../store/useFiltersStore'
import Instrument from './Instrument.vue'

const store = useFiltersStore()

const instruments = ref([])
const loading = ref(false)
const error = ref(null)

function buildApiFilters(settings) {
  return {
    quote_asset: settings.default_quote_asset,
    status: settings.default_status,
    exchange: settings.default_exchange,
    min_volume: settings.default_volume,
    min_deals: settings.default_deals,
    min_price: settings.default_price_above,
    max_price: settings.default_price_below,
    min_change: settings.default_change,
    // max_change: ... если появится в форме
  }
}

async function fetchInstruments() {
  loading.value = true
  error.value = null
  try {
    const apiFilters = buildApiFilters(store.filters)
    const params = new URLSearchParams(apiFilters).toString()
    const res = await fetch(`/api/dynamics?${params}`)
    instruments.value = await res.json()
  } catch (e) {
    error.value = e.message
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
