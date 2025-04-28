# app/services/exchange_adapter.rb
require 'net/http'
require 'json'

class ExchangeAdapter
  CACHE_KEY_PREFIX = 'exchange_ticker'
  PRICE_CACHE_TTL = 1.minute

  def self.fetch_tickers(exchange_slug, market_type, symbols)
    Rails.logger.info("
    [******]
    ExchangeAdapter: начало fetch_tickers
    Параметры запроса:
    - exchange_slug: #{exchange_slug}
    - market_type: #{market_type}
    - symbols: #{symbols.inspect}
    [******]")

    # Проверяем кеш
    cached_data = fetch_from_cache(exchange_slug, market_type, symbols)
    return cached_data.values if cached_data.size == symbols.size

    # Получаем конфигурацию биржи
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

    # Если есть batch_api_url, используем его
    results = if ex.batch_api_url.present?
      fetch_batch_data(ex, symbols)
    else
      fetch_individual_data(ex, symbols)
    end

    # Кешируем результаты
    cache_tickers(exchange_slug, market_type, results.index_by { |t| t[:symbol] })

    results
  end

  private

  def self.fetch_batch_data(ex, symbols)
    url = ex.batch_api_url % { symbols: symbols.join(',') }
    Rails.logger.info("ExchangeAdapter: batch запрос к API: #{url}")
    
    response = Net::HTTP.get_response(URI(url))
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("ExchangeAdapter: ошибка batch API, статус: #{response.code}")
      return []
    end

    data = JSON.parse(response.body)
    data = [data] unless data.is_a?(Array) # Некоторые API возвращают объект для одного символа

    data.map do |item|
      {
        symbol: item[ex.symbol_key || 'symbol'],
        last_price: item[ex.price_key].to_f,
        volume: item[ex.volume_key].to_f,
        price_change_percent: item[ex.change_key].to_f,
        exchange: ex.slug,
        market_type: ex.market_type
      }
    rescue => e
      Rails.logger.error("ExchangeAdapter: ошибка обработки данных: #{e.message}")
      nil
    end.compact
  end

  def self.fetch_individual_data(ex, symbols)
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

  def self.fetch_from_cache(exchange_slug, market_type, symbols)
    result = {}
    symbols.each do |symbol|
      cached = Rails.cache.read("#{CACHE_KEY_PREFIX}:#{exchange_slug}:#{symbol}")
      result[symbol] = cached if cached
    end
    result
  end

  def self.cache_tickers(exchange_slug, market_type, tickers)
    tickers.each do |symbol, data|
      Rails.cache.write(
        "#{CACHE_KEY_PREFIX}:#{exchange_slug}:#{symbol}",
        data,
        expires_in: PRICE_CACHE_TTL
      )
    end
  end
end
