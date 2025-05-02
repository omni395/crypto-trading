class Api::ExchangeController < ApplicationController
  # GET /api/exchange
  # Параметры: exchange, symbols[] (массив), фильтры (min_volume, max_price, ...)
  def index
    exchange = params[:exchange]
    symbols = Array(params[:symbols])

    # Пример фильтров
    min_volume = params[:min_volume]&.to_f
    max_price = params[:max_price]&.to_f
    min_change_percent = params[:min_change_percent]&.to_f

    tickers = ExchangeAdapter.fetch_tickers(exchange, symbols)

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

  # GET /api/exchange/chart_data
  # Параметры: exchange, symbol, interval
  def chart_data
    exchange = params[:exchange]
    symbol = params[:symbol]
    interval = params[:interval] || '1m' # Интервал по умолчанию

    begin
      chart_data = ExchangeAdapter.fetch_chart_data(exchange, symbol, interval)
      render json: chart_data
    rescue => e
      render json: { error: e.message }, status: 500
    end
  end
end
