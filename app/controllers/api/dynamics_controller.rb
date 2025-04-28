# frozen_string_literal: true

class Api::DynamicsController < ApplicationController
  # GET /api/dynamics
  def index
    begin
      Rails.logger.info("
      [******]
      DynamicsController: начало обработки запроса
      Параметры фильтров:
      - quote_asset: #{params[:quote_asset]}
      - status: #{params[:status]}
      - exchange: #{params[:exchange]}
      - min_volume: #{params[:min_volume]}
      - min_price: #{params[:min_price]}
      - max_price: #{params[:max_price]}
      - min_change: #{params[:min_change]}
      [******]")
  
      # Get cryptocurrencies based on filters
      cryptos = Cryptocurrency.where(
        quote_asset: params[:quote_asset],
        status: params[:status],
        exchange: params[:exchange]
      )
      
      Rails.logger.info("
      [******]
      DynamicsController: найдено криптовалют после базовой фильтрации: #{cryptos.size}
      Символы: #{cryptos.pluck(:symbol).join(', ')}
      [******]")
  
      # Get tickers from exchange
      tickers = ExchangeAdapter.fetch_tickers(params[:exchange], 'spot', cryptos.pluck(:symbol))
      
      Rails.logger.info("
      [******]
      DynamicsController: получено тикеров от биржи: #{tickers&.size}
      [******]")
  
      # Filter and process tickers
      filtered_tickers = tickers.compact.select do |ticker|
        next false unless ticker[:volume].present? && ticker[:last_price].present?
        
        volume = ticker[:volume].to_f
        price = ticker[:last_price].to_f
        change = ticker[:price_change_percent].to_f.abs
        
        passes = volume >= params[:min_volume].to_f &&
          price >= params[:min_price].to_f &&
          price <= params[:max_price].to_f &&
          change >= params[:min_change].to_f
  
        Rails.logger.info("
        [******]
        Проверка тикера #{ticker[:symbol]}:
        - Объем: #{volume} >= #{params[:min_volume]} = #{volume >= params[:min_volume].to_f}
        - Цена: #{price} >= #{params[:min_price]} && <= #{params[:max_price]} = #{price >= params[:min_price].to_f && price <= params[:max_price].to_f}
        - Изменение: #{change} >= #{params[:min_change]} = #{change >= params[:min_change].to_f}
        Прошел фильтры: #{passes}
        [******]")
  
        passes
      end
  
      Rails.logger.info("
      [******]
      DynamicsController: итоговое количество тикеров после фильтрации: #{filtered_tickers.size}
      Прошедшие символы: #{filtered_tickers.map { |t| t[:symbol] }.join(', ')}
      [******]")
  
      render json: filtered_tickers
    rescue => e
      Rails.logger.error "Error in DynamicsController: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def passes_dynamic_filters?(ticker, filters)
    return true if filters.blank?
    
    volume_ok = filters[:min_volume].blank? || 
                ticker[:volume].to_f >= filters[:min_volume].to_f
    
    deals_ok = filters[:min_deals].blank? || 
               ticker[:trades].to_i >= filters[:min_deals].to_i
               
    price_ok = if filters[:min_price].present? || filters[:max_price].present?
      price = ticker[:last_price].to_f
      min_price = filters[:min_price].to_f
      max_price = filters[:max_price].to_f
      
      price >= min_price && (max_price.zero? || price <= max_price)
    else
      true
    end
               
    change_ok = filters[:min_change].blank? || 
                ticker[:price_change_percent].to_f.abs >= filters[:min_change].to_f
                
    volume_ok && deals_ok && price_ok && change_ok
  end

  def build_instrument_data(crypto, ticker)
    {
      id: crypto.id,
      symbol: crypto.symbol,
      name: crypto.name,
      exchange: crypto.exchange,
      price: ticker[:last_price],
      volume: ticker[:volume],
      change: ticker[:price_change_percent],
      trades: ticker[:trades],
      is_favorite: current_user&.favorite_crypto?(crypto.id)
    }
  end
end
