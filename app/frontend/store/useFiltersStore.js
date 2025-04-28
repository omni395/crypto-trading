import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useFiltersStore = defineStore('filters', () => {
  // Все возможные фильтры пользователя
  const filters = ref({})

  function setFilters(newFilters) {
    filters.value = { ...filters.value, ...newFilters }
  }

  function resetFilters(defaults) {
    filters.value = { ...defaults }
  }

  return { filters, setFilters, resetFilters }
})
