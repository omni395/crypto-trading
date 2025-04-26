class Api::AdminController < ApplicationController
  before_action :authenticate_user!

  # POST /api/admin/refresh_binance
  def refresh_binance
    authorize :admin, :admin?
    BinanceSpotCryptocurrenciesFetcher.fetch_and_update!
    BinanceFuturesCryptocurrenciesFetcher.fetch_and_update!
    render json: { status: 'ok', message: 'Монеты с Binance (spot и futures) обновлены.' }
  end

  # private ensure_admin! больше не нужен, всё через pundit
end
