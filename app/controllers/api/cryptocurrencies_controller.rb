class Api::CryptocurrenciesController < ApplicationController
  # POST /api/cryptocurrencies/filter
  def filter
    quote_asset = params[:quote_asset].presence || 'USDT'
    filters = params[:filters] || {}
    pairs = FilteredPairsService.new(quote_asset).call
    results = FilteredCryptocurrencyDataService.new(pairs, filters.symbolize_keys).call
    render json: results
  end
end
