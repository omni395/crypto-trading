# frozen_string_literal: true

class Api::DynamicsController < ApplicationController
  # GET /api/dynamics
  def index
    begin
      # Get cryptocurrencies based on filters
      cryptos = Cryptocurrency.where(
        quote_asset: params[:quote_asset],
        status: params[:status],
        exchange: params[:exchange]
      )
  
      # Get tickers from exchange
      tickers = ExchangeAdapter.fetch_tickers(params[:exchange], 'spot', cryptos.pluck(:symbol))
      
      # Filter and process tickers
      filtered_tickers = tickers.compact.select do |ticker|
        next false unless ticker[:volume].present? && ticker[:last_price].present?
        
        volume = ticker[:volume].to_f
        price = ticker[:last_price].to_f
        change = ticker[:price_change_percent].to_f.abs
        
        volume >= params[:min_volume].to_f &&
          price >= params[:min_price].to_f &&
          price <= params[:max_price].to_f &&
          change >= params[:min_change].to_f
      end
  
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
