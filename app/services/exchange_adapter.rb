# app/services/exchange_adapter.rb
require 'net/http'
require 'json'

class ExchangeAdapter
  # Универсальный адаптер, использующий Exchange из базы
  def self.fetch_tickers(exchange_slug, market_type, symbols)
    Rails.logger.info("
    [******]
    ExchangeAdapter: начало fetch_tickers
    Параметры запроса:
    - exchange_slug: #{exchange_slug}
    - market_type: #{market_type}
    - symbols: #{symbols.inspect}
    [******]")

    ex = Exchange.find_by(slug: exchange_slug, market_type: market_type, status: 'active')
    unless ex
      Rails.logger.error("
      [******]
      ExchangeAdapter: биржа не найдена
      Параметры поиска:
      - slug: #{exchange_slug}
      - market_type: #{market_type}
      - status: active
      [******]")
      raise "Биржа не найдена или неактивна"
    end

    Rails.logger.info("
    [******]
    ExchangeAdapter: биржа найдена
    Конфигурация биржи:
    - api_url: #{ex.api_url}
    - price_key: #{ex.price_key}
    - volume_key: #{ex.volume_key}
    - change_key: #{ex.change_key}
    [******]")

    url_template = ex.api_url
    price_key = ex.price_key
    volume_key = ex.volume_key
    change_key = ex.change_key

    results = symbols.map do |symbol|
      url = "#{url_template}#{symbol}"  # Изменено формирование URL
      begin
        Rails.logger.info("ExchangeAdapter: запрос к API для #{symbol}: #{url}")
        res = Net::HTTP.get_response(URI(url))
        
        unless res.is_a?(Net::HTTPSuccess)
          Rails.logger.error("ExchangeAdapter: ошибка API для #{symbol}, статус: #{res.code}")
          next nil
        end

        data = JSON.parse(res.body)
        ticker = {
          symbol: symbol,
          last_price: data[price_key].to_f,
          volume: data[volume_key].to_f,
          price_change_percent: data[change_key].to_f,
          exchange: ex.slug,
          market_type: ex.market_type
        }

        Rails.logger.info("
        [******]
        ExchangeAdapter: получены данные для #{symbol}:
        - last_price: #{ticker[:last_price]}
        - volume: #{ticker[:volume]}
        - price_change_percent: #{ticker[:price_change_percent]}
        [******]")

        ticker
      rescue => e
        Rails.logger.error("
        [******]
        ExchangeAdapter: ошибка при получении данных
        - symbol: #{symbol}
        - url: #{url}
        - error: #{e.message}
        - backtrace: #{e.backtrace.first(5).join("\n")}
        [******]")
        nil
      end
    end

    Rails.logger.info("
    [******]
    ExchangeAdapter: завершение fetch_tickers
    Обработано символов: #{symbols.size}
    Успешно получено: #{results.compact.size}
    [******]")

    results
  end
end
