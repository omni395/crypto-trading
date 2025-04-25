class MainController < ApplicationController
  def index
    # Получить уникальные значения для селектов из базы
    @market_types = Cryptocurrency.distinct.pluck(:market_type)
    @quote_assets = Cryptocurrency.distinct.pluck(:quote_asset)
    @statuses = Cryptocurrency.distinct.pluck(:status)

    # Фильтрация только по нужным полям (без базовой монеты и лишних)
    filters = {}
    filters[:market_type] = params[:market_type] if params[:market_type].present?
    filters[:quote_asset] = params[:quote_asset] if params[:quote_asset].present?
    filters[:status] = params[:status] if params[:status].present?
    filters[:exchange] = params[:exchange] if params[:exchange].present?

    # Если фильтр поиска не задан или пустой, показываем все монеты без фильтрации
    if params[:q].present? && params[:q][:symbol_or_base_asset_or_quote_asset_or_name_cont].present?
      @q = Cryptocurrency.ransack(params[:q])
      @cryptocurrencies = @q.result.where(filters)
    else
      @q = Cryptocurrency.ransack({})
      @cryptocurrencies = filters.any? ? Cryptocurrency.where(filters) : Cryptocurrency.all
    end
    @cryptocurrencies_count = @cryptocurrencies.size
    Rails.logger.info("[CRYPTO] Всего монет в списке: #{@cryptocurrencies_count}")
    respond_to do |format|
      format.html do
      end
      format.turbo_stream do
      end
    end
  end

  def refresh_cryptocurrencies
    UpdateCryptocurrenciesJob.perform_later
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace('refresh-btn', partial: 'components/refreshing'),
          turbo_stream.replace('instruments-frame', partial: 'components/instruments', locals: { cryptocurrencies: Cryptocurrency.all })
        ]
      }
      format.html { redirect_to root_path, notice: 'Обновление запущено!' }
    end
  end
end
