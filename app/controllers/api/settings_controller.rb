class Api::SettingsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  # GET /api/settings
  def show
    # Для незалогиненных отдаём дефолты
    if user_signed_in? && current_user
      Rails.logger.info("[API] settings#show for user=#{current_user.id}, settings=#{current_user.settings.inspect}")
      render json: current_user.settings_with_defaults
    else
      render json: User::DEFAULT_SETTINGS
    end
  end

  # PATCH /api/settings
  def update
    # Если params[:settings] пустая строка или nil, используем остальные параметры
    settings = params[:settings].presence || params.to_unsafe_h.except(:controller, :action, :format, :settings, :authenticity_token)
    # Удаляем _method из settings перед сохранением
    settings = settings.except(:_method, '_method') if settings.respond_to?(:except)
    # Подставить дефолты для пустых значений при первом сохранении
    if current_user.settings.blank?
      settings = User::DEFAULT_SETTINGS.merge(settings).transform_values { |v| v.nil? || v == "" ? User::DEFAULT_SETTINGS[v] : v }
    end
    Rails.logger.info("[API] settings#update for user=#{current_user.id}, incoming=#{settings.inspect}")
    current_user.update!(settings: settings)
    Rails.logger.info("[API] settings#update after save user=#{current_user.id}, settings=#{current_user.settings.inspect}")
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Настройки успешно сохранены.' }
      format.json { render json: current_user.settings }
    end
  end

  private

  def settings_params
    params[:settings].presence || params.to_unsafe_h.except(:controller, :action, :format, :settings, :authenticity_token)
  end
end
