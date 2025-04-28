import { Modal } from "flowbite";

// Контроллер для кнопок "По дефолту" и "Обновить монеты"
export default class extends Controller {
  static targets = [
    "defaultQuoteAsset",
    "defaultStatus",
    "defaultVolume",
    "defaultDeals",
    "defaultChange",
    "defaultPriceAbove",
    "defaultPriceBelow",
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
    console.log('[UserSettings] Stimulus controller CONNECTED:', this.element);
    // Логируем открытие модалки (когда появляется в DOM)
    const modalEl = document.getElementById('settings-modal');
    if (modalEl) {
      console.log('[UserSettings] Модалка присутствует в DOM:', modalEl);
      modalEl.addEventListener('show.tw.modal', () => {
        console.log('[UserSettings] Модалка ОТКРЫТА (show.tw.modal)');
      });
      modalEl.addEventListener('hide.tw.modal', () => {
        console.log('[UserSettings] Модалка ЗАКРЫТА (hide.tw.modal)');
      });
    } else {
      console.log('[UserSettings] Модалка НЕ найдена в DOM при connect');
    }
    const form = this.element.querySelector('form');
    console.log('[UserSettings] Найден ли form внутри controller.element:', !!form, form);
    if (form) {
      form.addEventListener('ajax:success', () => {
        console.log('[UserSettings] ajax:success event TRIGGERED');
        window.dispatchEvent(new CustomEvent('settings:updated'));
        console.log('[UserSettings] Событие settings:updated отправлено');
        // Логируем попытку закрытия модалки
        const modalEl = document.getElementById('settings-modal');
        console.log('[UserSettings] Попытка найти модалку:', modalEl);
        if (modalEl) {
          let modal = Modal.getInstance(modalEl);
          console.log('[UserSettings] Modal.getInstance:', modal);
          if (!modal) {
            modal = new Modal(modalEl);
            console.log('[UserSettings] Новый инстанс Modal создан:', modal);
          }
          if (modal) {
            modal.hide();
            console.log('[UserSettings] Вызван modal.hide()');
          } else {
            console.log('[UserSettings] Не удалось создать инстанс Modal');
          }
        } else {
          console.log('[UserSettings] Не найден элемент модалки с id settings-modal');
        }
      });
      console.log('[UserSettings] Подписка на ajax:success добавлена');
    } else {
      console.log('[UserSettings] Не найден form внутри controller.element');
    }
  }

  dispatchSettingsUpdated() {
    window.dispatchEvent(new CustomEvent('settings:updated'));
    console.log('[UserSettings] Событие settings:updated отправлено');
  }
}
