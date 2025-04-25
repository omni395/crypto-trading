import { Controller } from "@hotwired/stimulus";

// Связка модалки настроек и фильтров через localStorage
export default class extends Controller {
  static targets = [
    // Только реально используемые для фильтрации поля
    "default_market_type", "default_quote_asset", "default_status", "default_exchange",
    // Остальные — как заглушки, чтобы не было ошибок (существуют в форме)
    "default_volume", "default_volume_currency", "default_deals", "default_change", "default_price_above", "default_price_below"
  ];

  connect() {
    // Проверяем авторизацию через data-user-signed-in на <body>
    const isSignedIn = document.body.dataset.userSignedIn === "true";
    console.log('[settings] connect: controller initialized, isSignedIn:', isSignedIn);
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
    // Логируем событие загрузки turbo-frame инструментов
    document.addEventListener('turbo:frame-load', (event) => {
      if (event.target.id === 'instruments-frame') {
        const count = event.target.querySelectorAll('.instrument-row').length;
        console.log(`[settings] instruments-frame обновлён, монет в DOM: ${count}`);
      }
    });
  }

  // Сохраняет значения из модалки настроек в localStorage и/или на сервере
  saveDefaults(event) {
    event.preventDefault();
    const isSignedIn = document.body.dataset.userSignedIn === "true";
    const settings = {
      default_market_type: this.default_market_typeTarget ? this.default_market_typeTarget.value : undefined,
      default_quote_asset: this.default_quote_assetTarget ? this.default_quote_assetTarget.value : undefined,
      default_status: this.default_statusTarget ? this.default_statusTarget.value : undefined,
      default_exchange: this.default_exchangeTarget ? this.default_exchangeTarget.value : undefined
      // Остальные параметры не используются для фильтрации
    };
    console.log('[settings] saveDefaults: сохраняем настройки', settings);
    Object.entries(settings).forEach(([k, v]) => localStorage.setItem(k, v));
    if (isSignedIn) {
      fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name=\'csrf-token\']').content },
        body: JSON.stringify(settings)
      })
        .then(r => r.json())
        .then(data => {
          console.log('[settings] saveDefaults: PATCH success', data);
          this.reloadInstrumentsFrame(settings);
        })
        .catch(e => {
          console.log('[settings] saveDefaults: PATCH error', e);
        });
    } else {
      this.reloadInstrumentsFrame(settings);
    }
  }

  // Загружает значения по умолчанию в модалку (заглушки)
  loadDefaultsToFilters() {
    console.log('[settings] loadDefaultsToFilters: загружаем значения по умолчанию в фильтры');
    // Только для существующих полей-заглушек
    if (this.hasDefaultVolumeTarget) this.default_volumeTarget.value = 300000;
    if (this.hasDefaultDealsTarget) this.default_dealsTarget.value = 100000;
    if (this.hasDefaultChangeTarget) this.default_changeTarget.value = 0;
    if (this.hasDefaultPriceAboveTarget) this.default_price_aboveTarget.value = 0.01;
    if (this.hasDefaultPriceBelowTarget) this.default_price_belowTarget.value = 5;
    if (this.hasDefaultVolumeCurrencyTarget) this.default_volume_currencyTarget.value = 'coin';
  }

  // Применяет значения к фильтрам и в модальное окно настроек
  applySettingsToFilters(settings) {
    console.log('[settings] applySettingsToFilters: применяем настройки к фильтрам', settings);
    if (this.hasDefaultMarketTypeTarget && settings.default_market_type)
      this.default_market_typeTarget.value = settings.default_market_type;
    if (this.hasDefaultQuoteAssetTarget && settings.default_quote_asset)
      this.default_quote_assetTarget.value = settings.default_quote_asset;
    if (this.hasDefaultStatusTarget && settings.default_status)
      this.default_statusTarget.value = settings.default_status;
    if (this.hasDefaultExchangeTarget && settings.default_exchange)
      this.default_exchangeTarget.value = settings.default_exchange;
  }

  resetToDefaults(event) {
    event.preventDefault();
    if (this.hasDefaultMarketTypeTarget) this.default_market_typeTarget.value = '';
    if (this.hasDefaultQuoteAssetTarget) this.default_quote_assetTarget.value = '';
    if (this.hasDefaultStatusTarget) this.default_statusTarget.value = '';
    if (this.hasDefaultExchangeTarget) this.default_exchangeTarget.value = '';
    // Заглушки
    if (this.hasDefaultVolumeTarget) this.default_volumeTarget.value = 300000;
    if (this.hasDefaultDealsTarget) this.default_dealsTarget.value = 100000;
    if (this.hasDefaultChangeTarget) this.default_changeTarget.value = 0;
    if (this.hasDefaultPriceAboveTarget) this.default_price_aboveTarget.value = 0.01;
    if (this.hasDefaultPriceBelowTarget) this.default_price_belowTarget.value = 5;
    if (this.hasDefaultVolumeCurrencyTarget) this.default_volume_currencyTarget.value = 'coin';
  }

  reloadInstrumentsFrame(settings) {
    console.log('[settings] reloadInstrumentsFrame: отправка запроса на обновление инструментов с фильтрами', settings);
    const params = new URLSearchParams({
      market_type: settings.default_market_type,
      quote_asset: settings.default_quote_asset,
      status: settings.default_status,
      exchange: settings.default_exchange
    });
    const frame = document.getElementById('instruments-frame');
    if (frame) {
      frame.src = `/main/index?${params.toString()}`;
    } else {
      window.location.reload();
    }
  }
}