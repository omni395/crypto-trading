class MainController < ApplicationController
  def index
    @q = Cryptocurrency.ransack(params[:q])
    @cryptocurrencies = @q.result.order(volume: :desc)
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
          turbo_stream.replace('instruments-frame', partial: 'components/instruments', locals: { cryptocurrencies: Cryptocurrency.order(volume: :desc) })
        ]
      }
      format.html { redirect_to root_path, notice: 'Обновление запущено!' }
    end
  end
end
