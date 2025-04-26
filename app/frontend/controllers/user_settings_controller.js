import { Controller } from "@hotwired/stimulus"

// Контроллер для кнопок "По дефолту" и "Обновить монеты"
export default class extends Controller {
  static targets = [
    "defaultMarketType",
    "defaultQuoteAsset",
    "defaultStatus",
    "defaultExchange"
  ];

  resetToDefaults(event) {
    event.preventDefault();
    // Значения по умолчанию (должны совпадать с DEFAULT_SETTINGS в user.rb)
    const defaults = {
      defaultMarketType: "spot",
      defaultQuoteAsset: "USDT",
      defaultStatus: "trading",
      defaultExchange: "binance",
      defaultVolume: "300000",
      defaultDeals: "100000",
      defaultChange: "0",
      defaultPriceAbove: "0.01",
      defaultPriceBelow: "5"
    };
    // Сбросить select'ы и input'ы к дефолтным значениям
    if (this.hasDefaultMarketTypeTarget) this.defaultMarketTypeTarget.value = defaults.defaultMarketType;
    if (this.hasDefaultQuoteAssetTarget) this.defaultQuoteAssetTarget.value = defaults.defaultQuoteAsset;
    if (this.hasDefaultStatusTarget) this.defaultStatusTarget.value = defaults.defaultStatus;
    if (this.hasDefaultExchangeTarget) this.defaultExchangeTarget.value = defaults.defaultExchange;
    // Неактивные поля (если будут активны)
    const vol = this.element.querySelector('[data-user-settings-target="defaultVolume"]');
    if (vol) vol.value = defaults.defaultVolume;
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
}
