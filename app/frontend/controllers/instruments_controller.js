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
          const symbols = Array.from(frame.querySelectorAll('[data-crypto-row]')).map(row => row.dataset.symbol);
          console.log(`[Instruments] Символы монет после обновления:`, symbols);
          this.fetchDynamicData();
        } else {
          console.warn('[Instruments] Не удалось найти новый turbo-frame в ответе');
        }
      });
  }

  async fetchDynamicData() {
    const rows = Array.from(document.querySelectorAll('[data-crypto-row]'));
    const symbols = rows.map(row => row.dataset.symbol).filter(Boolean);
    console.log('[fetchDynamicData] Найдено строк:', rows.length, 'Символов:', symbols);
    if (symbols.length === 0) {
      console.warn('[fetchDynamicData] Нет символов для запроса');
      return;
    }
    const exchange = rows[0]?.dataset.exchange || 'binance';
    const marketType = rows[0]?.dataset.marketType || 'spot';
    console.log(`[fetchDynamicData] Биржа: ${exchange}, Тип рынка: ${marketType}`);
    const params = new URLSearchParams();
    params.append('exchange', exchange);
    params.append('market_type', marketType);
    symbols.forEach(symbol => params.append('symbols[]', symbol));
    console.log('[fetchDynamicData] Параметры запроса:', params.toString());
    fetch(`/api/market_data?${params.toString()}`)
      .then(r => {
        console.log('[fetchDynamicData] Ответ сервера status:', r.status);
        return r.ok ? r.json() : Promise.reject(r);
      })
      .then(data => {
        const tickers = data.tickers || [];
        console.log('[fetchDynamicData] Получено тикеров:', tickers.length, tickers);
        rows.forEach(row => {
          const ticker = tickers.find(t => t && t.symbol === row.dataset.symbol);
          if (ticker) {
            row.style.display = '';
            const priceCell = row.querySelector('[data-crypto-price]');
            if (priceCell) priceCell.textContent = ticker.last_price;
            const changeCell = row.querySelector('[data-crypto-change]');
            if (changeCell) changeCell.textContent = `${ticker.price_change_percent}%`;
            console.log(`[fetchDynamicData] Обновлён ряд для ${row.dataset.symbol}:`, ticker);
          } else {
            row.style.display = 'none';
            console.warn(`[fetchDynamicData] Нет данных для ${row.dataset.symbol}, скрываю строку`);
          }
        });
        console.log('[fetchDynamicData] Обработка завершена, тикеров:', tickers.length);
        document.dispatchEvent(new CustomEvent('marketdata:fetched', { detail: { tickers } }));
      })
      .catch(err => {
        console.error('[fetchDynamicData] Ошибка при получении данных', err);
        rows.forEach(row => row.style.display = '');
        console.log('[fetchDynamicData] Обработка завершена с ошибкой');
        document.dispatchEvent(new CustomEvent('marketdata:fetched', { detail: { tickers: [] } }));
      });
  }

  // Метод ручного обновления списка инструментов
  refresh() {
    fetch(this.urlValue, { headers: { Accept: 'application/json' } })
      .then(r => r.json())
      .then(data => {
        if (data.cryptocurrencies) {
          console.log(`[Instruments] Получено монет: ${data.cryptocurrencies.length}`);
          const serverSymbols = data.cryptocurrencies.map(c => c.symbol);
          console.log('[Instruments] Символы монет с сервера:', serverSymbols);
          // Здесь можно обновить DOM turbo-frame вручную или через Turbo Streams
          // Например, если сервер отдаёт turbo_stream — Turbo.renderStreamMessage(html)
        } else {
          console.warn('[Instruments] Не удалось получить данные монет');
        }
      });
  }
}