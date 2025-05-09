require 'net/http'
require 'json'

class CryptocurrenciesFetcher
  def self.fetch_and_update!(exchange_slug)
    exchange = Exchange.find_by!(slug: exchange_slug, status: 'active')
    
    uri = URI(exchange.api_url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    db_cryptos = Cryptocurrency.where(exchange: exchange_slug).pluck(:symbol, :base_asset, :quote_asset, :status).index_by { |s, _, _, _| s }
    api_symbols = []

    data['symbols'].each do |item|
      symbol = item['symbol']
      base_asset = item['baseAsset']
      quote_asset = item['quoteAsset']
      status = item['status'].downcase
      api_symbols << symbol

      db_crypto = db_cryptos[symbol]
      if db_crypto.nil?
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
          Cryptocurrency.where(symbol: symbol, exchange: exchange_slug).update_all(
            base_asset: base_asset, 
            quote_asset: quote_asset, 
            status: status
          )
        end
      end
    end

    Cryptocurrency.where(exchange: exchange_slug).where.not(symbol: api_symbols).update_all(status: 'inactive')
  end
end
