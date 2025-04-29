class ExchangeAdapter
  def self.fetch_tickers(exchange_slug, symbols)
    ex = Exchange.find_by(slug: exchange_slug, status: 'active')
    raise "Биржа не найдена или неактивна" unless ex

    url_template = ex.api_url

    # Используем новые поля для маппинга ключей
    price_key  = ex.price_key
    volume_key = ex.volume_key
    change_key = ex.change_key

    symbols.map do |symbol|
      url = url_template % { symbol: symbol }
      begin
        res = Net::HTTP.get_response(URI(url))
        next nil unless res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body)
        {
          symbol: symbol,
          last_price: data[price_key],
          volume: data[volume_key],
          price_change_percent: data[change_key]
        }
      rescue => e
        Rails.logger.error("ExchangeAdapter: ошибка для #{symbol}: #{e.message}")
        nil
      end
    end
  end
end