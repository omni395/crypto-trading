import { createApp } from 'vue';
import { createPinia } from 'pinia'
import { useFiltersStore } from '../store/useFiltersStore';

// Основные компоненты
import App from '../vue/App.vue';
import Instruments from '../vue/Instruments.vue';
import SettingsModal from '../vue/SettingsModal.vue';
import UserDropdown from '../vue/UserDropdown.vue';

// Монтирование дропдауна пользователя
if (document.getElementById('vue-user-dropdown')) {
  const app = createApp(UserDropdown);
  app.mount('#vue-user-dropdown');
}

// Монтирование модалки настроек
if (document.getElementById('vue-settings-modal')) {
  const pinia = createPinia();
  const app = createApp(SettingsModal);
  app.use(pinia);
  app.config.devtools = true;
  app.mount('#vue-settings-modal');
}

// Монтирование основного приложения инструментов
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