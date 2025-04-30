# Фоновый джоб для кеширования популярных срезов инструментов
class InstrumentsCacheJob < ApplicationJob
  queue_as :default

  # Можно расширить список фильтров (например, брать уникальные из логов или БД)
  POPULAR_FILTERS = [
    { exchange: 'binance_spot', quote_asset: 'USDT', status: 'trading' },
    { exchange: 'binance_futures', quote_asset: 'USDT', status: 'trading' }
  ]

  def perform
    POPULAR_FILTERS.each do |filters|
      # Получаем криптовалюты по базовым фильтрам
      cryptos = Cryptocurrency.where(filters)
      # Получаем тикеры с биржи
      raw_tickers = ExchangeAdapter.fetch_tickers(filters[:exchange], cryptos.pluck(:symbol))
      # Кладём в кеш
      InstrumentsCacheService.write(filters, raw_tickers)
    end
  end
end
