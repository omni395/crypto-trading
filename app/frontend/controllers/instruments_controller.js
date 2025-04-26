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
          this.fetchDynamicData();
        } else {
          console.warn('[Instruments] Не удалось найти новый turbo-frame в ответе');
        }
      });
  }

  async fetchDynamicData() {
    const rows = Array.from(document.querySelectorAll('[data-crypto-row]'));
    // Предполагается, что у каждой строки есть data-symbol="BTCUSDT"
    const symbols = rows.map(row => row.dataset.symbol).filter(Boolean);
    if (symbols.length === 0) return;

    // Binance REST API не поддерживает batch для /ticker/24hr, делаем параллельные запросы
    const requests = symbols.map(symbol =>
      fetch(`https://api.binance.com/api/v3/ticker/24hr?symbol=${symbol}`)
        .then(r => r.ok ? r.json().then(data => ({ symbol, ...data })) : null)
        .catch(() => null)
    );
    const tickers = await Promise.all(requests);

    rows.forEach(row => {
      const ticker = tickers.find(t => t && t.symbol === row.dataset.symbol);
      if (ticker) {
        // Пример динамического фильтра: volume > 1000 и изменение > 2%
        if (Number(ticker.volume) > 1000 && Math.abs(Number(ticker.priceChangePercent)) > 2) {
          row.style.display = '';
          // Можно обновить цену/объем/изменение прямо в DOM
          const priceCell = row.querySelector('[data-crypto-price]');
          if (priceCell) priceCell.textContent = ticker.lastPrice;
          const changeCell = row.querySelector('[data-crypto-change]');
          if (changeCell) changeCell.textContent = `${ticker.priceChangePercent}%`;
        } else {
          row.style.display = 'none';
        }
      } else {
        row.style.display = 'none';
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