# app/services/binance_spot_cryptocurrencies_fetcher.rb
require 'net/http'
require 'json'

class BinanceSpotCryptocurrenciesFetcher
  API_URL = 'https://api.binance.com/api/v3/exchangeInfo'

  def self.fetch_and_update!
    Rails.logger.info "
    [******]
    [CryptoListing] Start update at #{Time.current}
    [******]"
    uri = URI(API_URL)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    # Получаем текущие монеты из базы
    db_cryptos = Cryptocurrency.where(exchange: 'binance_spot').pluck(:symbol, :base_asset, :quote_asset, :status).index_by { |s, _, _, _| s }
    Rails.logger.info "
    [******]
    [CryptoListing] SPOT: В базе монет: #{db_cryptos.size}
    [******]"
    api_symbols = []

    # Находим биржу один раз перед циклом
    exchange = Exchange.find_by!(slug: 'binance_spot')

    data['symbols'].each do |item|
      symbol = item['symbol']
      base_asset = item['baseAsset']
      quote_asset = item['quoteAsset']
      status = item['status'].downcase
      api_symbols << symbol

      db_crypto = db_cryptos[symbol]
      if db_crypto.nil?
        # Новая монета - используем объект exchange вместо строки
        Cryptocurrency.create!(
          symbol: symbol,
          base_asset: base_asset,
          quote_asset: quote_asset,
          status: status,
          exchange: exchange
        )
      else
        db_base, db_quote, db_status = db_crypto[1], db_crypto[2], db_crypto[3]
        if db_base != base_asset || db_quote != quote_asset || db_status != status
          Cryptocurrency.where(symbol: symbol, exchange: 'binance_spot').update_all(base_asset: base_asset, quote_asset: quote_asset, status: status)
        end
      end
    end

    Rails.logger.info "
    [******]
    [CryptoListing] SPOT: Получено из API: #{api_symbols.size} монет
    [******]"
    # Деактивируем монеты, которых больше нет в API
    Cryptocurrency.where(exchange: 'binance_spot').where.not(symbol: api_symbols).update_all(status: 'inactive')
    Rails.logger.info "
    [******]
    [CryptoListing] SPOT: Деактивировано: #{Cryptocurrency.where(exchange: 'binance_spot').where.not(symbol: api_symbols).count} монет
    [******]"
    Rails.logger.info "
    [******]
    [CryptoListing] Finish update at #{Time.current}
    [******]"
  end
end
