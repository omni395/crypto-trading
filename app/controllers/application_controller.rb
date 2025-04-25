class ApplicationController < ActionController::Base
  before_action :set_crypto_selects

  private

  def set_crypto_selects
    @market_types = Cryptocurrency.market_types_list
    @quote_assets = Cryptocurrency.quote_assets_list(params[:market_type])
    @statuses = Cryptocurrency.statuses_list(params[:market_type])
    Rails.logger.info("[SETTINGS_MODAL] quote_assets: \", "+@quote_assets.inspect)
    Rails.logger.info("[SETTINGS_MODAL] statuses: \", "+@statuses.inspect)
  end
end
