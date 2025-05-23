class Api::UserSettingsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  # GET /api/settings
  def show
    # Для незалогиненных отдаём дефолты
    if user_signed_in? && current_user
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

    # Гарантируем, что settings — всегда хэш
    settings = begin
      if settings.is_a?(String)
        JSON.parse(settings) rescue {}
      elsif settings.respond_to?(:to_unsafe_h)
        settings.to_unsafe_h
      else
        settings || {}
      end
    end

    user_settings = current_user.settings.is_a?(Hash) ? current_user.settings : {}

    # Всегда подставлять дефолты для пустых значений
    settings = User::DEFAULT_SETTINGS.merge(user_settings).merge(settings)
    settings = settings.transform_values.with_index do |v, idx|
      v.nil? || v == "" ? User::DEFAULT_SETTINGS.values[idx] : v
    end

    current_user.update!(settings: settings)
    render json: current_user.settings
  end

  private

  def settings_params
    params[:settings].presence || params.to_unsafe_h.except(:controller, :action, :format, :settings, :authenticity_token)
  end
end
