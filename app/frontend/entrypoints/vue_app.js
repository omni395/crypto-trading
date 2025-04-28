import { createApp } from 'vue';
import { createPinia } from 'pinia'
import SettingsModal from '../vue/SettingsModal.vue';
import App from '../vue/App.vue';
import Instruments from '../vue/Instruments.vue';
import Toastr from '../vue/Toastr.vue';

if (document.getElementById('vue-settings-modal')) {
  const app = createApp(SettingsModal);
  app.config.devtools = true; // Enable Vue Devtools
  app.mount('#vue-settings-modal');
}

if (document.getElementById('vue-instruments')) {
  const filters = JSON.parse(document.getElementById('vue-instruments').dataset.filters || '{}')
  const pinia = createPinia();
  const app = createApp(App);
  app.use(pinia);
  import('../store/useFiltersStore').then(({ useFiltersStore }) => {
    const store = useFiltersStore();
    store.setFilters(filters);
    app.mount('#vue-instruments');
  });
}

console.log('Vue entrypoint loaded');