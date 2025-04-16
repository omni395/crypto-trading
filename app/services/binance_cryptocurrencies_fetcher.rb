# app/services/binance_cryptocurrencies_fetcher.rb
require 'net/http'
require 'json'

class BinanceCryptocurrenciesFetcher
  API_URL = 'https://api.binance.com/api/v3/ticker/24hr'

  def self.fetch_and_update!
    uri = URI(API_URL)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data.each do |item|
      symbol = item['symbol']
      base_asset, quote_asset = parse_symbol(symbol)
      Cryptocurrency.find_or_initialize_by(symbol: symbol).tap do |crypto|
        crypto.base_asset = base_asset
        crypto.quote_asset = quote_asset
        crypto.volume = item['quoteVolume'].to_f
        crypto.trades = item['count']
        crypto.price_change_percent = item['priceChangePercent'].to_f
        crypto.last_price = item['lastPrice'].to_f
        crypto.data_updated_at = Time.current
        crypto.save!
      end
    end
  end

  def self.parse_symbol(symbol)
    # Примитивно: разбиваем по USDT, BTC, ETH, BNB, TUSD, FDUSD, TRY, EUR, RUB, UAH, USDC и т.д.
    # Можно расширять список базовых валют
    bases = %w[USDT BTC ETH BNB TUSD FDUSD TRY EUR RUB UAH USDC]
    base = bases.find { |b| symbol.end_with?(b) }
    if base
      [symbol.gsub(base, ''), base]
    else
      [symbol, '']
    end
  end
end
