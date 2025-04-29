import { defineStore } from 'pinia'
import { ref } from 'vue'

// Дефолтные значения фильтров
export const DEFAULT_FILTERS = {
  default_volume: "300000",
  default_deals: "100000",
  default_change: "2",
  default_price_above: "0.01",
  default_price_below: "5",
  default_basecoin: "USDT",
  default_exchange: "binance_spot",
  default_quote_asset: "USDT",
  default_status: "trading"
}

export const useFiltersStore = defineStore('filters', () => {
  // Все возможные фильтры пользователя
  const filters = ref({ ...DEFAULT_FILTERS }) // Инициализируем сразу дефолтными значениями

  function setFilters(newFilters) {
    // ГАРАНТИРОВАННО: всегда мержим с дефолтами!
    filters.value = { ...DEFAULT_FILTERS, ...newFilters }
  }

  function resetFilters() {
    filters.value = { ...DEFAULT_FILTERS }
  }

  // Добавляем геттер для получения текущих фильтров
  function getCurrentFilters() {
    return filters.value
  }

  async function loadUserFilters() {
    try {
      const res = await fetch('/api/user_settings')
      if (!res.ok) throw new Error('Ошибка загрузки фильтров')
      const apiFilters = await res.json()
      // Берём только валидные значения (не undefined и не null)
      const cleanApiFilters = Object.fromEntries(
        Object.entries(apiFilters).filter(([k, v]) => v !== undefined && v !== null)
      )
      filters.value = { ...DEFAULT_FILTERS, ...cleanApiFilters }
    } catch (e) {
      console.warn('[FiltersStore] Не удалось загрузить фильтры пользователя:', e)
      // Если ошибка — не сбрасываем filters, оставляем дефолты
    }
  }

  return { filters, setFilters, resetFilters, getCurrentFilters, DEFAULT_FILTERS, loadUserFilters }
})