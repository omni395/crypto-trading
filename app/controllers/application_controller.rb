class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :set_crypto_selects

  private

  def set_crypto_selects
    @quote_assets = Cryptocurrency.quote_assets_list
    @statuses = Cryptocurrency.statuses_list
    @exchanges = Exchange.active.order(:name).pluck(:name, :slug)
    Rails.logger.info("[SETTINGS_MODAL] quote_assets: #{@quote_assets.inspect}")
    Rails.logger.info("[SETTINGS_MODAL] statuses: #{@statuses.inspect}")
  end
end
