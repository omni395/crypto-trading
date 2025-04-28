class Api::ExchangeController < ApplicationController
  # GET /api/exchange
  # Параметры: exchange, market_type, symbols[] (массив), фильтры (min_volume, max_price, ...)
  def index
    exchange = params[:exchange]
    market_type = params[:market_type]
    symbols = Array(params[:symbols])

    # Пример фильтров
    min_volume = params[:min_volume]&.to_f
    max_price = params[:max_price]&.to_f
    min_change_percent = params[:min_change_percent]&.to_f

    tickers = ExchangeAdapter.fetch_tickers(exchange, market_type, symbols)

    # Применяем фильтры (можно вынести в отдельный сервис)
    filtered = tickers.select do |ticker|
      next false unless ticker
      pass = true
      pass &&= ticker[:volume].to_f >= min_volume if min_volume
      pass &&= ticker[:last_price].to_f <= max_price if max_price
      pass &&= ticker[:price_change_percent].to_f >= min_change_percent if min_change_percent
      pass
    end

    render json: { tickers: filtered }
  rescue => e
    render json: { error: e.message }, status: 500
  end
end
