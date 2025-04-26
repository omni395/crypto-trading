import { Controller } from "@hotwired/stimulus"

// Контроллер для кнопок "По дефолту" и "Обновить монеты"
export default class extends Controller {
  static targets = [
    "defaultQuoteAsset",
    "defaultStatus",
    "defaultExchange"
  ];

  resetToDefaults(event) {
    event.preventDefault();
    // Значения по умолчанию (должны совпадать с DEFAULT_SETTINGS в user.rb)
    const defaults = {
      defaultQuoteAsset: "USDT",
      defaultStatus: "trading",
      defaultExchange: "binance",
      defaultVolume: "300000",
      defaultDeals: "100000",
      defaultChange: "2",
      defaultPriceAbove: "0.01",
      defaultPriceBelow: "5"
    };
    // Сбросить select'ы и input'ы к дефолтным значениям
    const quote = this.element.querySelector('[data-user-settings-target="defaultQuoteAsset"]');
    if (quote) quote.value = defaults.defaultQuoteAsset;
    const status = this.element.querySelector('[data-user-settings-target="defaultStatus"]');
    if (status) status.value = defaults.defaultStatus;
    const exchange = this.element.querySelector('[data-user-settings-target="defaultExchange"]');
    if (exchange) exchange.value = defaults.defaultExchange;
    const volume = this.element.querySelector('[data-user-settings-target="defaultVolume"]');
    if (volume) volume.value = defaults.defaultVolume;
    const deals = this.element.querySelector('[data-user-settings-target="defaultDeals"]');
    if (deals) deals.value = defaults.defaultDeals;
    const change = this.element.querySelector('[data-user-settings-target="defaultChange"]');
    if (change) change.value = defaults.defaultChange;
    const above = this.element.querySelector('[data-user-settings-target="defaultPriceAbove"]');
    if (above) above.value = defaults.defaultPriceAbove;
    const below = this.element.querySelector('[data-user-settings-target="defaultPriceBelow"]');
    if (below) below.value = defaults.defaultPriceBelow;
  }

  refreshCoins(event) {
    event.preventDefault();
    if (!window.confirm('Вы действительно хотите принудительно обновить монеты с Binance (spot и futures)? Это может занять до минуты.')) {
      return;
    }
    fetch('/api/admin/refresh_binance', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'ok') {
          alert('Монеты успешно обновлены!');
          // Можно добавить автоматическое обновление списка монет, если нужно
        } else {
          alert('Ошибка: ' + (data.message || data.error || 'Неизвестная ошибка'));
        }
      })
      .catch(e => {
        alert('Ошибка при обновлении монет: ' + e.message);
      });
  }

  connect() {
    const form = this.element.querySelector('form');
    if (form) {
      form.addEventListener('ajax:success', () => {
        window.dispatchEvent(new CustomEvent('settings:updated'));
        console.log('[UserSettings] Событие settings:updated отправлено');
      });
    }
  }

  dispatchSettingsUpdated() {
    window.dispatchEvent(new CustomEvent('settings:updated'));
    console.log('[UserSettings] Событие settings:updated отправлено');
  }
}
