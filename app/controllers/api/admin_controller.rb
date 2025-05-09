class Api::AdminController < ApplicationController
  before_action :authenticate_user!

  def update_cryptocurrencies
    Exchange.active.each do |exchange|
      CryptocurrenciesFetcher.fetch_and_update!(exchange.slug)
    end
    render json: { status: 'success' }
  end

end
