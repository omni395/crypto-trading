class MainController < ApplicationController
  def index
    @cryptocurrencies = Cryptocurrency.order(volume: :desc).limit(50)
  end
end
