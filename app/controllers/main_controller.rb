class MainController < ApplicationController
  def index
    # Получить уникальные значения для селектов из базы (для модалки настроек)
    @market_types = Cryptocurrency.distinct.pluck(:market_type)
    @quote_assets = Cryptocurrency.distinct.pluck(:quote_asset)
    @statuses = Cryptocurrency.distinct.pluck(:status)

    # Фильтрация только по поисковому параметру (живой поиск)
    if params[:q].present? && params[:q][:symbol_or_base_asset_or_quote_asset_or_name_cont].present?
      @q = Cryptocurrency.ransack(params[:q])
      @cryptocurrencies = @q.result
    else
      @q = Cryptocurrency.ransack({})
      @cryptocurrencies = Cryptocurrency.all
    end

    @cryptocurrencies_count = @cryptocurrencies.size
    Rails.logger.info("[CRYPTO] Всего монет в списке: #{@cryptocurrencies_count}")
    Rails.logger.info("[INSTRUMENTS_FRAME] index: Количество монет: #{@cryptocurrencies_count}")
    respond_to do |format|
      format.html do
      end
      format.turbo_stream do
      end
    end
  end
end