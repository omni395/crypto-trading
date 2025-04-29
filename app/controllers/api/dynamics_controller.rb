# frozen_string_literal: true

class Api::DynamicsController < ApplicationController
  # GET /api/dynamics
  def index
    begin
      # Базовые фильтры для кеша (без min_volume и т.д.)
      cache_filters = {
        exchange: params[:exchange],
        quote_asset: params[:quote_asset],
        status: params[:status]
      }.compact

      # Ключ кеша и попытка достать сырые данные
      raw_tickers = InstrumentsCacheService.fetch(cache_filters)
      unless raw_tickers
        # Получаем криптовалюты по базовым фильтрам
        cryptos = Cryptocurrency.where(cache_filters)
        # Получаем тикеры с биржи
        raw_tickers = ExchangeAdapter.fetch_tickers(params[:exchange], cryptos.pluck(:symbol))
        # Сохраняем в кеш
        InstrumentsCacheService.write(cache_filters, raw_tickers)
      end

      # Фильтрация по min_volume, min_price, max_price, min_change и т.д.
      filtered_tickers = raw_tickers.compact.select do |ticker|
        next false unless ticker[:volume].present? && ticker[:last_price].present?

        volume = ticker[:volume].to_f
        price = ticker[:last_price].to_f
        change = ticker[:price_change_percent].to_f.abs

        passes = true
        passes &&= volume >= params[:min_volume].to_f if params[:min_volume].present?
        passes &&= price >= params[:min_price].to_f if params[:min_price].present?
        passes &&= price <= params[:max_price].to_f if params[:max_price].present?
        passes &&= change >= params[:min_change].to_f if params[:min_change].present?

        passes
      end

      # Формируем итоговую структуру для фронта
      cryptos ||= Cryptocurrency.where(cache_filters).to_a
      instruments = filtered_tickers.map do |ticker|
        crypto = cryptos.find { |c| c.symbol == ticker[:symbol] }
        build_instrument_data(crypto, ticker) if crypto
      end.compact

      render json: instruments
    rescue => e
      Rails.logger.error "[API::DynamicsController] ERROR: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}" 
      render json: { error: e.message, class: e.class.name, backtrace: e.backtrace[0..5] }, status: :internal_server_error
    end
  end

  private

  def build_instrument_data(crypto, ticker)
    {
      id: crypto.id,
      symbol: crypto.symbol,
      base_asset: crypto.base_asset,
      quote_asset: crypto.quote_asset,
      status: crypto.status,
      name: crypto.name,
      exchange: crypto.exchange&.slug,
      exchange_name: crypto.exchange&.name,
      last_price: ticker[:last_price].to_f,
      volume: ticker[:volume].to_f,
      trades: ticker[:trades].to_i,
      price_change_percent: ticker[:price_change_percent].to_f,
      # TODO: Реализовать логику favorites позже
      is_favorite: current_user&.respond_to?(:favorite_crypto?) ? current_user.favorite_crypto?(crypto.id) : false,
      raw: {
        crypto: crypto.as_json,
        ticker: ticker.as_json
      }
    }
  end
end
