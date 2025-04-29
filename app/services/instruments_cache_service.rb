# Сервис для кеширования и получения "сырых" тикеров по фильтрам
class InstrumentsCacheService
  CACHE_TTL = 6.minutes

  require 'redis'
  
  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://redis:6379/0')
  end

  # Генерирует уникальный ключ кеша по базовым фильтрам
  def self.cache_key(filters)
    "dynamics:#{filters[:exchange]}:#{filters[:quote_asset]}:#{filters[:status]}"
  end

  # Получить "сырые" тикеры из кеша (или nil)
  def self.fetch(filters)
    key = cache_key(filters)
    cached = redis.get(key)
    cached ? JSON.parse(cached, symbolize_names: true) : nil
  end

  # Сохранить "сырые" тикеры в кеш
  def self.write(filters, raw_tickers)
    key = cache_key(filters)
    redis.set(key, raw_tickers.to_json, ex: CACHE_TTL)
  end
end
