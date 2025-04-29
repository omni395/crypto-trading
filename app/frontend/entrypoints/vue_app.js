import { createApp } from 'vue';
import { createPinia } from 'pinia'
import { useFiltersStore } from '../store/useFiltersStore';

// Основные компоненты
import App from '../vue/App.vue';
import Instruments from '../vue/Instruments.vue';
import SettingsModal from '../vue/SettingsModal.vue';

// Основные импорты
if (document.getElementById('vue-settings-modal')) {
  const pinia = createPinia();
  const app = createApp(SettingsModal);
  app.use(pinia);
  app.config.devtools = true;
  app.mount('#vue-settings-modal');
}

if (document.getElementById('vue-instruments')) {
  const userFilters = JSON.parse(document.getElementById('vue-instruments').dataset.filters || '{}');
  
  const pinia = createPinia();
  const app = createApp(App);
  app.use(pinia);
  
  const store = useFiltersStore();
  store.setFilters({
    ...store.DEFAULT_FILTERS,
    ...userFilters
  });
  app.mount('#vue-instruments');
}

console.log('Vue entrypoint loaded');

// Дефолтные значения фильтров
const DEFAULT_FILTERS = {
  default_volume: "300000",
  default_deals: "100000",
  default_change: "2",
  default_price_above: "0.01",
  default_price_below: "5",
  default_basecoin: "USDT",
  default_exchange: "Binance Spot",
  default_quote_asset: "USDT",
  default_status: "trading"
};