# Service for filtering and caching trading pairs by quote asset (e.g. USDT, USDC)
require 'redis'

class FilteredPairsService
  CACHE_TTL = 10.minutes

  def initialize(quote_asset)
    @quote_asset = quote_asset.upcase
    @redis = Redis.new # configure as needed
    @cache_key = "pairs:#{@quote_asset}"
  end

  def call
    cached = @redis.get(@cache_key)
    return JSON.parse(cached) if cached

    pairs = Cryptocurrency.where(quote_asset: @quote_asset).pluck(:symbol)
    @redis.set(@cache_key, pairs.to_json, ex: CACHE_TTL)
    pairs
  end
end
