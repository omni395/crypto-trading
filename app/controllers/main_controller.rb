class MainController < ApplicationController
  def index
    # Получить уникальные значения для селектов из базы (для модалки настроек)
    @quote_assets = Cryptocurrency.distinct.pluck(:quote_asset)
    @statuses = Cryptocurrency.distinct.pluck(:status)

    # Получаем настройки пользователя (или дефолтные)
    settings = current_user&.settings_with_defaults || User::DEFAULT_SETTINGS

    filters = {}
    filters[:quote_asset] = settings["default_quote_asset"]
    filters[:status] = settings["default_status"]
    filters[:exchange] = settings["exchange"]
    filters.compact!

    # Поиск и ransack удалены — поиск теперь только через API/Vue
    @cryptocurrencies = Cryptocurrency.where(filters)

    # Получить количество монет в списке
    @cryptocurrencies_count = @cryptocurrencies.size

    # Ответ только HTML (Turbo удалён)
    respond_to do |format|
      format.html
    end
  end
end