class Api::PairsController < ApplicationController
  # GET /api/pairs?quote_asset=USDT
  def index
    quote_asset = params[:quote_asset].presence || 'USDT'
    pairs = Cryptocurrency.where(quote_asset: quote_asset).pluck(:symbol)
    render json: { pairs: pairs }
  end
end
