# frozen_string_literal: true

class Api::DynamicsController < ApplicationController
  # GET /api/dynamics
  def index
    # Получаем фильтры пользователя
    filters = params.permit(:quote_asset, :status, :exchange, :min_volume, :min_deals, :min_price, :max_price, :min_change)

    # 1. Фильтрация по статике (только по реально существующим полям)
    scope = Cryptocurrency.all
    scope = scope.where(quote_asset: filters[:quote_asset]) if filters[:quote_asset].present?
    scope = scope.where(status: filters[:status]) if filters[:status].present?
    scope = scope.where(exchange: filters[:exchange]) if filters[:exchange].present?
    coins = scope.to_a

    # 2. Получаем динамику с биржи (примерная функция, реализуй под свой API)
    dynamics = fetch_binance_data(coins)

    # 3. Фильтрация по динамическим полям (в Ruby, не в SQL)
    filtered = dynamics.select do |dyn|
      (filters[:min_volume].blank? || dyn[:volume].to_f >= filters[:min_volume].to_f) &&
      (filters[:min_deals].blank? || dyn[:trades].to_i >= filters[:min_deals].to_i) &&
      (filters[:min_price].blank? || dyn[:last_price].to_f >= filters[:min_price].to_f) &&
      (filters[:max_price].blank? || dyn[:last_price].to_f <= filters[:max_price].to_f) &&
      (filters[:min_change].blank? || dyn[:price_change_percent].to_f >= filters[:min_change].to_f)
    end

    render json: filtered
  end

  private

  # Примерная функция для получения динамики с биржи
  def fetch_binance_data(coins)
    # Здесь должен быть твой реальный код для получения динамики с Binance или другой биржи
    # Например, один запрос к API, сопоставление по symbol и возврат массива хэшей
    # [{ symbol: 'BTCUSDT', volume: 123, trades: 456, last_price: 12345.6, price_change_percent: 1.23, ... }, ...]
    []
  end
end
