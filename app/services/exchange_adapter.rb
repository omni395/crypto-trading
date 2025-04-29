# app/services/exchange_adapter.rb
require 'net/http'
require 'json'

class ExchangeAdapter
  CACHE_KEY_PREFIX = 'exchange_ticker'
  PRICE_CACHE_TTL = 1.minute

  def self.fetch_tickers(exchange_slug, symbols)
    Rails.logger.info("[******] ExchangeAdapter: начало fetch_tickers [******]")

    cached_data = fetch_from_cache(exchange_slug, symbols)
    cached_symbols = cached_data.keys
    missing_symbols = symbols - cached_symbols

    fresh_data = []
    if missing_symbols.any?
      ex = Exchange.find_by(slug: exchange_slug, status: 'active')
      raise "Биржа не найдена или неактивна" unless ex

      url_template = ex.api_url
      price_key = ex.price_key
      volume_key = ex.volume_key
      change_key = ex.change_key
      trades_key = ex.trades_key

      fresh_data = missing_symbols.map do |symbol|
        url = url_template % { symbol: symbol }
        begin
          res = Net::HTTP.get_response(URI(url))
          next nil unless res.is_a?(Net::HTTPSuccess)
          data = JSON.parse(res.body)
          {
            symbol: symbol,
            last_price: data[price_key],
            volume: data[volume_key],
            price_change_percent: data[change_key],
            trades: data[trades_key],
            exchange: ex.slug
          }
        rescue => e
          Rails.logger.error("ExchangeAdapter: ошибка для #{symbol}: #{e.message}")
          nil
        end
      end.compact

      # Кешируем новые данные
      cache_tickers(exchange_slug, fresh_data.index_by { |t| t[:symbol] })
    end

    # Собираем все тикеры в исходном порядке symbols
    all_data = symbols.map { |symbol| cached_data[symbol] || fresh_data.find { |d| d[:symbol] == symbol } }.compact

    Rails.logger.info("[******] ExchangeAdapter: завершение fetch_tickers [******]")
    all_data
  end

  private

  def self.fetch_batch_data(ex, symbols)
    # Форматируем символы в нужный формат для API
    formatted_symbols = symbols.map { |s| "\"#{s}\"" }.join(',')
    url = ex.batch_api_url % { symbols: formatted_symbols }
    
    Rails.logger.info("[******] ExchangeAdapter: batch запрос к API: #{url} [******]")
    
    response = Net::HTTP.get_response(URI(url))
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[******] ExchangeAdapter: ошибка batch API, статус: #{response.code} [******]")
      Rails.logger.error("Тело ответа: #{response.body}")
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
        trades: item[ex.trades_key || 'count'],
        exchange: ex.slug
      }
    rescue => e
      Rails.logger.error("ExchangeAdapter: ошибка обработки данных: #{e.message}")
      nil
    end.compact
  end

  def self.fetch_individual_data(ex, symbols)
    Rails.logger.info("[******] ExchangeAdapter: биржа найдена [******]")
    Rails.logger.info("Конфигурация биржи:")
    Rails.logger.info("- api_url: #{ex.api_url}")
    Rails.logger.info("- price_key: #{ex.price_key}")
    Rails.logger.info("- volume_key: #{ex.volume_key}")
    Rails.logger.info("- change_key: #{ex.change_key}")
    Rails.logger.info("- symbol_key: #{ex.symbol_key}")

    url_template = ex.api_url
    price_key = ex.price_key
    volume_key = ex.volume_key
    change_key = ex.change_key
    trades_key = ex.trades_key

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
          trades: data[trades_key || 'count'],
          exchange: ex.slug
        }

        Rails.logger.info("[******] ExchangeAdapter: получены данные для #{symbol}:")
        Rails.logger.info("- last_price: #{ticker[:last_price]}")
        Rails.logger.info("- volume: #{ticker[:volume]}")
        Rails.logger.info("- price_change_percent: #{ticker[:price_change_percent]}")
        Rails.logger.info("[******]")

        ticker
      rescue => e
        Rails.logger.error("[******] ExchangeAdapter: ошибка при получении данных")
        Rails.logger.error("- symbol: #{symbol}")
        Rails.logger.error("- url: #{url}")
        Rails.logger.error("- error: #{e.message}")
        Rails.logger.error("- backtrace: #{e.backtrace.first(5).join("\n")}")
        Rails.logger.error("[******]")
        nil
      end
    end

    Rails.logger.info("[******] ExchangeAdapter: завершение fetch_tickers")
    Rails.logger.info("Обработано символов: #{symbols.size}")
    Rails.logger.info("Успешно получено: #{results.compact.size}")
    Rails.logger.info("[******]")

    results
  end

  def self.fetch_from_cache(exchange_slug, symbols)
    result = {}
    symbols.each do |symbol|
      cached = Rails.cache.read("#{CACHE_KEY_PREFIX}:#{exchange_slug}:#{symbol}")
      result[symbol] = cached if cached
    end
    result
  end

  def self.cache_tickers(exchange_slug, tickers)
    tickers.each do |symbol, data|
      Rails.cache.write(
        "#{CACHE_KEY_PREFIX}:#{exchange_slug}:#{symbol}",
        data,
        expires_in: PRICE_CACHE_TTL
      )
    end
  end
end
