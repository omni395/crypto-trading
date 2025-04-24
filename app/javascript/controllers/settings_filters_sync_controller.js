import { Controller } from "@hotwired/stimulus";

// Связка модалки настроек и фильтров через localStorage
export default class extends Controller {
  static targets = [
    // Settings modal fields
    "defaultVolume", "defaultVolumeCurrency", "defaultDeals", "defaultChange", "defaultPriceAbove", "defaultPriceBelow", "defaultBasecoin", "defaultExchange", "defaultFutures", "defaultFavorites",
    // Filters fields
    "filterVolume", "filterVolumeCurrency", "filterDeals", "filterChange", "filterPriceAbove", "filterPriceBelow", "filterPair", "filterExchange", "filterFutures", "filterFavorites"
  ];

  connect() {
    // Проверяем авторизацию через data-user-signed-in на <body>
    const isSignedIn = document.body.dataset.userSignedIn === "true";
    console.log('[settings] connect: isSignedIn', isSignedIn);
    if (isSignedIn) {
      // Если авторизован — грузим настройки с сервера
      fetch('/api/settings', {
        headers: { 'Accept': 'application/json' }
      })
        .then(r => {
          console.log('[settings] fetch /api/settings status', r.status);
          return r.json();
        })
        .then(settings => {
          console.log('[settings] loaded from backend', settings);
          // Применять только если settings не пустой
          if (settings && Object.keys(settings).length > 0) {
            this.applySettingsToFilters(settings);
          } else {
            this.loadDefaultsToFilters();
          }
        })
        .catch(e => {
          console.log('[settings] fetch /api/settings ERROR', e);
          this.loadDefaultsToFilters();
        }); // fallback на localStorage
    } else {
      // Если не авторизован — localStorage
      this.loadDefaultsToFilters();
    }
  }

  // Сохраняет значения из модалки настроек в localStorage и/или на сервере
  saveDefaults(event) {
    event.preventDefault();
    const isSignedIn = document.body.dataset.userSignedIn === "true";
    const settings = {
      defaultVolume: this.defaultVolumeTarget.value,
      defaultVolumeCurrency: this.defaultVolumeCurrencyTarget.value,
      defaultDeals: this.defaultDealsTarget.value,
      defaultChange: this.defaultChangeTarget.value,
      defaultPriceAbove: this.defaultPriceAboveTarget.value,
      defaultPriceBelow: this.defaultPriceBelowTarget.value,
      defaultBasecoin: this.defaultBasecoinTarget.value,
      defaultExchange: this.defaultExchangeTarget.value,
      defaultFutures: this.defaultFuturesTarget.checked ? '1' : '',
      defaultFavorites: this.defaultFavoritesTarget.checked ? '1' : ''
    };
    Object.entries(settings).forEach(([k, v]) => localStorage.setItem(k, v));
    if (isSignedIn) {
      fetch('/api/settings', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ settings }) 
      })
        .then(r => r.json())
        .then(() => {
          this.loadDefaultsToFilters();
          // Успешное сохранение настроек
          console.log('[toastr] Будет вызван toastr.success: Настройки успешно сохранены!');
          toastr.success('Настройки успешно сохранены!');
          // Снять фокус с активного элемента перед скрытием модалки (универсально)
          if (document.activeElement instanceof HTMLElement) {
            document.activeElement.blur();
          }
          // Закрыть модалку после сохранения
          const modal = document.getElementById('settings-modal');
          if (modal) {
            modal.classList.add('hidden');
            modal.setAttribute('aria-hidden', 'true');
            // Универсальный возврат фокуса
            const openBtn = document.getElementById('settings-btn');
            if (openBtn && openBtn.offsetParent !== null) {
              setTimeout(() => openBtn.focus(), 100);
            } else {
              // Найти первый видимый интерактивный элемент в <main>
              const firstFocusable = document.querySelector('main button, main [href], main input, main select, main textarea, main [tabindex]:not([tabindex="-1"])');
              if (firstFocusable) {
                setTimeout(() => firstFocusable.focus(), 100);
              } else {
                setTimeout(() => { if (document.body) document.body.focus(); }, 100);
              }
            }
          }
        });
    } else {
      this.loadDefaultsToFilters();
      // Успешное сохранение настроек
      console.log('[toastr] Будет вызван toastr.success: Настройки успешно сохранены!');
      toastr.success('Настройки успешно сохранены!');
      // Снять фокус с активного элемента перед скрытием модалки (универсально)
      if (document.activeElement instanceof HTMLElement) {
        document.activeElement.blur();
      }
      // Закрыть модалку после сохранения
      const modal = document.getElementById('settings-modal');
      if (modal) {
        modal.classList.add('hidden');
        modal.setAttribute('aria-hidden', 'true');
        // Универсальный возврат фокуса
        const openBtn = document.getElementById('settings-btn');
        if (openBtn && openBtn.offsetParent !== null) {
          setTimeout(() => openBtn.focus(), 100);
        } else {
          // Найти первый видимый интерактивный элемент в <main>
          const firstFocusable = document.querySelector('main button, main [href], main input, main select, main textarea, main [tabindex]:not([tabindex="-1"])');
          if (firstFocusable) {
            setTimeout(() => firstFocusable.focus(), 100);
          } else {
            setTimeout(() => { if (document.body) document.body.focus(); }, 100);
          }
        }
      }
    }
  }

  // Загружает значения по умолчанию в фильтры
  loadDefaultsToFilters() {
    if (this.hasFilterVolumeTarget) this.filterVolumeTarget.value = localStorage.getItem('defaultVolume') || '';
    if (this.hasFilterVolumeCurrencyTarget) this.filterVolumeCurrencyTarget.value = localStorage.getItem('defaultVolumeCurrency') || 'coin';
    if (this.hasFilterDealsTarget) this.filterDealsTarget.value = localStorage.getItem('defaultDeals') || '';
    if (this.hasFilterChangeTarget) this.filterChangeTarget.value = localStorage.getItem('defaultChange') || '';
    if (this.hasFilterPriceAboveTarget) this.filterPriceAboveTarget.value = localStorage.getItem('defaultPriceAbove') || '';
    if (this.hasFilterPriceBelowTarget) this.filterPriceBelowTarget.value = localStorage.getItem('defaultPriceBelow') || '';
    if (this.hasFilterPairTarget) this.filterPairTarget.value = localStorage.getItem('defaultPair') || '';
    if (this.hasFilterExchangeTarget) this.filterExchangeTarget.value = localStorage.getItem('defaultExchange') || 'binance';
    if (this.hasFilterFuturesTarget) this.filterFuturesTarget.checked = !!localStorage.getItem('defaultFutures');
    if (this.hasFilterFavoritesTarget) this.filterFavoritesTarget.checked = !!localStorage.getItem('defaultFavorites');
  }

  // Применяет значения к фильтрам и в модальное окно настроек
  applySettingsToFilters(settings) {
    // Фильтры (основная форма)
    if (this.hasFilterVolumeTarget) this.filterVolumeTarget.value = settings.defaultVolume || '';
    if (this.hasFilterVolumeCurrencyTarget) this.filterVolumeCurrencyTarget.value = settings.defaultVolumeCurrency || 'coin';
    if (this.hasFilterDealsTarget) this.filterDealsTarget.value = settings.defaultDeals || '';
    if (this.hasFilterChangeTarget) this.filterChangeTarget.value = settings.defaultChange || '';
    if (this.hasFilterPriceAboveTarget) this.filterPriceAboveTarget.value = settings.defaultPriceAbove || '';
    if (this.hasFilterPriceBelowTarget) this.filterPriceBelowTarget.value = settings.defaultPriceBelow || '';
    if (this.hasFilterPairTarget) this.filterPairTarget.value = settings.defaultPair || '';
    if (this.hasFilterExchangeTarget) this.filterExchangeTarget.value = settings.defaultExchange || 'binance';
    if (this.hasFilterFuturesTarget) this.filterFuturesTarget.checked = !!settings.defaultFutures;
    if (this.hasFilterFavoritesTarget) this.filterFavoritesTarget.checked = !!settings.defaultFavorites;

    // Модалка настроек
    if (this.hasDefaultVolumeTarget) this.defaultVolumeTarget.value = settings.defaultVolume || '';
    if (this.hasDefaultVolumeCurrencyTarget) this.defaultVolumeCurrencyTarget.value = settings.defaultVolumeCurrency || 'coin';
    if (this.hasDefaultDealsTarget) this.defaultDealsTarget.value = settings.defaultDeals || '';
    if (this.hasDefaultChangeTarget) this.defaultChangeTarget.value = settings.defaultChange || '';
    if (this.hasDefaultPriceAboveTarget) this.defaultPriceAboveTarget.value = settings.defaultPriceAbove || '';
    if (this.hasDefaultPriceBelowTarget) this.defaultPriceBelowTarget.value = settings.defaultPriceBelow || '';
    if (this.hasDefaultBasecoinTarget) this.defaultBasecoinTarget.value = settings.defaultBasecoin || '';
    if (this.hasDefaultExchangeTarget) this.defaultExchangeTarget.value = settings.defaultExchange || 'binance';
    if (this.hasDefaultFuturesTarget) this.defaultFuturesTarget.checked = !!settings.defaultFutures;
    if (this.hasDefaultFavoritesTarget) this.defaultFavoritesTarget.checked = !!settings.defaultFavorites;
  }
}
