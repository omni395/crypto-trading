import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    console.log('[Instruments] Stimulus controller connected');
    window.addEventListener('settings:updated', this.reloadFrame.bind(this));
  }

  reloadFrame() {
    const frame = document.getElementById('instruments-frame');
    if (!frame) {
      console.warn('[Instruments] Не найден turbo-frame instruments-frame');
      return;
    }
    const url = this.urlValue || window.location.pathname;
    console.log(`[Instruments] Запрос на обновление turbo-frame по url: ${url}`);
    fetch(url, { headers: { Accept: 'text/html' } })
      .then(r => r.text())
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const newFrame = doc.getElementById('instruments-frame');
        if (newFrame) {
          frame.innerHTML = newFrame.innerHTML;
          const count = frame.querySelectorAll('[data-crypto-row]').length;
          console.log(`[Instruments] turbo-frame обновлён, монет: ${count}`);
        } else {
          console.warn('[Instruments] Не удалось найти новый turbo-frame в ответе');
        }
      });
  }

  // Метод ручного обновления списка инструментов
  refresh() {
    fetch(this.urlValue, { headers: { Accept: 'application/json' } })
      .then(r => r.json())
      .then(data => {
        if (data.cryptocurrencies) {
          console.log(`[Instruments] Получено монет: ${data.cryptocurrencies.length}`);
          // Здесь можно обновить DOM turbo-frame вручную или через Turbo Streams
          // Например, если сервер отдаёт turbo_stream — Turbo.renderStreamMessage(html)
        } else {
          console.warn('[Instruments] Не удалось получить данные монет');
        }
      });
  }
}