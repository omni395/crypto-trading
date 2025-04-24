class Api::PairsController < ApplicationController
  # GET /api/pairs?quote_asset=USDT
  def index
    quote_asset = params[:quote_asset].presence || 'USDT'
    pairs = FilteredPairsService.new(quote_asset).call
    render json: { pairs: pairs }
  end
end
