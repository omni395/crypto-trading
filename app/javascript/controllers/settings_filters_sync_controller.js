import { Controller } from "@hotwired/stimulus";

// Связка модалки настроек и фильтров через localStorage
export default class extends Controller {
  static targets = [
    // Settings modal fields
    "defaultSort", "defaultVolume", "defaultVolumeCurrency", "defaultDeals", "defaultChange", "defaultPriceAbove", "defaultPriceBelow", "defaultBasecoin", "defaultExchange",
    // Filters fields
    "filterVolume", "filterDeals", "filterChange", "filterPriceAbove", "filterPriceBelow", "filterPair", "filterExchange"
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
      defaultSort: this.defaultSortTarget.value,
      defaultVolume: this.defaultVolumeTarget.value,
      defaultVolumeCurrency: this.defaultVolumeCurrencyTarget.value,
      defaultDeals: this.defaultDealsTarget.value,
      defaultChange: this.defaultChangeTarget.value,
      defaultPriceAbove: this.defaultPriceAboveTarget.value,
      defaultPriceBelow: this.defaultPriceBelowTarget.value,
      defaultBasecoin: this.defaultBasecoinTarget.value,
      defaultExchange: this.defaultExchangeTarget.value
    };
    Object.entries(settings).forEach(([k, v]) => localStorage.setItem(k, v));
    if (isSignedIn) {
      fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
        body: JSON.stringify(settings)
      })
        .then(r => r.json())
        .then(data => {
          // Можно добавить уведомление об успехе
        });
    }
  }

  // Загружает значения по умолчанию в фильтры
  loadDefaultsToFilters() {
    // Загружает значения по умолчанию в фильтры
    this.filterVolumeTarget.value = 300000;
    this.filterDealsTarget.value = 100000;
    this.filterChangeTarget.value = 0;
    this.filterPriceAboveTarget.value = 0.01;
    this.filterPriceBelowTarget.value = 5;
    this.filterPairTarget.value = '';
    this.filterExchangeTarget.value = 'binance';
  }

  // Применяет значения к фильтрам и в модальное окно настроек
  applySettingsToFilters(settings) {
    // Применяет значения к фильтрам и в модальное окно настроек
    this.defaultSortTarget.value = settings.default_sort;
    this.defaultVolumeTarget.value = settings.default_volume;
    this.defaultVolumeCurrencyTarget.value = settings.default_volume_currency;
    this.defaultDealsTarget.value = settings.default_deals;
    this.defaultChangeTarget.value = settings.default_change;
    this.defaultPriceAboveTarget.value = settings.default_price_above;
    this.defaultPriceBelowTarget.value = settings.default_price_below;
    this.defaultBasecoinTarget.value = settings.default_basecoin;
    this.defaultExchangeTarget.value = settings.default_exchange;
  }

  // Сброс к дефолтам (по кнопке)
  resetToDefaults(event) {
    event.preventDefault();
    this.defaultSortTarget.value = 'volume';
    this.defaultVolumeTarget.value = 300000;
    this.defaultVolumeCurrencyTarget.value = 'coin';
    this.defaultDealsTarget.value = 100000;
    this.defaultChangeTarget.value = 0;
    this.defaultPriceAboveTarget.value = 0.01;
    this.defaultPriceBelowTarget.value = 5;
    this.defaultBasecoinTarget.value = 'USDT';
    this.defaultExchangeTarget.value = 'binance';
    // Можно добавить уведомление об успехе
  }

  // Загружает список монет с сервера и обновляет select
  refreshCoins(event) {
    event.preventDefault();
    const select = this.defaultBasecoinTarget;
    select.disabled = true;
    select.innerHTML = '';
    const loadingOption = document.createElement('option');
    loadingOption.textContent = 'Загрузка...';
    loadingOption.value = '';
    select.appendChild(loadingOption);
    fetch('/api/pairs?quote_asset=USDT')
      .then(r => r.json())
      .then(data => {
        select.innerHTML = '';
        if (data.pairs && data.pairs.length > 0) {
          data.pairs.forEach(pair => {
            const option = document.createElement('option');
            option.value = pair;
            option.textContent = pair;
            select.appendChild(option);
          });
        } else {
          const option = document.createElement('option');
          option.value = '';
          option.textContent = 'Нет монет';
          select.appendChild(option);
        }
        select.disabled = false;
      })
      .catch(e => {
        select.innerHTML = '';
        const option = document.createElement('option');
        option.value = '';
        option.textContent = 'Ошибка загрузки';
        select.appendChild(option);
        select.disabled = false;
        alert('Ошибка при загрузке монет');
        console.error(e);
      });
  }
}
