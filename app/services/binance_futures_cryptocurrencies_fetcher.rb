# app/services/binance_futures_cryptocurrencies_fetcher.rb
require 'net/http'
require 'json'

class BinanceFuturesCryptocurrenciesFetcher
  API_URL = 'https://fapi.binance.com/fapi/v1/exchangeInfo'

  def self.fetch_and_update!
    Rails.logger.info "
    [******]
    [CryptoListing:Futures] Start update at #{Time.current}
    [******]
    "
    uri = URI(API_URL)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    db_cryptos = Cryptocurrency.where(exchange: 'binance_futures').pluck(:symbol, :base_asset, :quote_asset, :status).index_by { |s, _, _, _| s }
    Rails.logger.info "
    [******]
    [CryptoListing:Futures] В базе монет: #{db_cryptos.size}
    [******]
    "
    api_symbols = []

    data['symbols'].each do |item|
      symbol = item['symbol']
      base_asset = item['baseAsset']
      quote_asset = item['quoteAsset']
      status = item['status'].downcase
      api_symbols << symbol

      db_crypto = db_cryptos[symbol]
      if db_crypto.nil?
        Cryptocurrency.create!(symbol: symbol, base_asset: base_asset, quote_asset: quote_asset, status: status, exchange: 'binance_futures')
      else
        db_base, db_quote, db_status = db_crypto[1], db_crypto[2], db_crypto[3]
        if db_base != base_asset || db_quote != quote_asset || db_status != status
          Cryptocurrency.where(symbol: symbol, exchange: 'binance_futures').update_all(base_asset: base_asset, quote_asset: quote_asset, status: status)
        end
      end
    end

    Rails.logger.info "
    [******]
    [CryptoListing:Futures] Получено из API: #{api_symbols.size} монет
    [******]
    "
    deactivated_count = Cryptocurrency.where(exchange: 'binance_futures').where.not(symbol: api_symbols).count
    Cryptocurrency.where(exchange: 'binance_futures').where.not(symbol: api_symbols).update_all(status: 'inactive')
    Rails.logger.info "
    [******]
    [CryptoListing:Futures] Деактивировано: #{deactivated_count} монет
    [******]
    "
    Rails.logger.info "
    [******]
    [CryptoListing:Futures] Finish update at #{Time.current}
    [******]
    "
  end
end
