class Api::InstrumentsController < ApplicationController
  before_action :authenticate_user!, only: [:favorites]

  # GET /api/instruments
  # Фильтрация монет по настройкам пользователя или дефолтным
  def index
    settings = current_user&.settings_with_defaults || User::DEFAULT_SETTINGS

    filters = {}
    filters[:quote_asset] = settings["default_quote_asset"]
    filters[:status] = settings["default_status"]
    filters[:exchange] = settings["exchange"]
    filters.compact!

    # Сначала пытаемся получить из кеша
    instruments = InstrumentsCacheService.fetch(filters)
    if instruments.nil?
      # Если нет в кеше — собираем и кешируем
      instruments = InstrumentsCacheService.build_and_cache(filters)
    else
    end

    render json: { cryptocurrencies: instruments }
  end

  # GET /api/instruments/favorites
  # Возвращает избранные монеты пользователя
  def favorites
    # Предполагается, что у пользователя есть поле favorite_cryptos (массив id или символов)
    fav_ids = current_user.favorite_cryptos || []
    cryptocurrencies = Cryptocurrency.where(id: fav_ids)
    render json: { favorites: cryptocurrencies }
  end
end
