class MainController < ApplicationController
  def index
    # Получить уникальные значения для селектов из базы (для модалки настроек)
    @market_types = Cryptocurrency.distinct.pluck(:market_type)
    @quote_assets = Cryptocurrency.distinct.pluck(:quote_asset)
    @statuses = Cryptocurrency.distinct.pluck(:status)

    # Получаем настройки пользователя (или дефолтные)
    settings = current_user&.settings_with_defaults || User::DEFAULT_SETTINGS

    filters = {}
    filters[:market_type] = settings["default_market_type"]
    filters[:quote_asset] = settings["default_quote_asset"]
    filters[:status] = settings["default_status"]
    filters[:exchange] = settings["default_exchange"]
    filters.compact!

    # Фильтрация только по поисковому параметру (живой поиск)
    if params[:q].present? && params[:q][:symbol_or_base_asset_or_quote_asset_or_name_cont].present?
      @q = Cryptocurrency.ransack(params[:q])
      @cryptocurrencies = @q.result.where(filters)
    else
      @q = Cryptocurrency.ransack({})
      @cryptocurrencies = Cryptocurrency.where(filters)
    end

    # Получить количество монет в списке
    @cryptocurrencies_count = @cryptocurrencies.size

    # Логирование
    Rails.logger.info("[INSTRUMENTS_FRAME] index: Количество монет: #{@cryptocurrencies_count}")

    # Ответ HTML и Turbo Stream
    respond_to do |format|
      format.html do
      end
      format.turbo_stream do
      end
    end
  end
end