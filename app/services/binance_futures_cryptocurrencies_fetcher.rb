# app/services/binance_futures_cryptocurrencies_fetcher.rb
require 'net/http'
require 'json'

class BinanceFuturesCryptocurrenciesFetcher
  API_URL = 'https://fapi.binance.com/fapi/v1/ticker/24hr'

  def self.fetch_and_update!
    Rails.logger.info "[CryptoListing:Futures] Start update at #{Time.current}"
    uri = URI(API_URL)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data.each do |item|
      symbol = item['symbol']
      base_asset = item['symbol'].sub(/#{item['quoteAsset']}\z/, '')
      quote_asset = item['quoteAsset']
      Cryptocurrency.find_or_initialize_by(symbol: symbol, market_type: 'futures').tap do |crypto|
        crypto.base_asset = base_asset
        crypto.quote_asset = quote_asset
        crypto.status = 'active' # Можно доработать по API
        crypto.market_type = 'futures'
        crypto.save!
      end
    end
    Rails.logger.info "[CryptoListing:Futures] Finish update at #{Time.current}"
  end
end
