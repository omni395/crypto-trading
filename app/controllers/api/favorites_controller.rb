# frozen_string_literal: true

class Api::FavoritesController < ApplicationController
  before_action :authenticate_user!

  # GET /api/favorites
  # Возвращает список избранных монет пользователя
  def index
    fav_ids = current_user.favorite_cryptos || []
    cryptocurrencies = Cryptocurrency.where(id: fav_ids)
    render json: { cryptocurrencies: cryptocurrencies }
  end

  # POST /api/favorites
  # Добавляет монету в избранное
  def create
    fav_ids = current_user.favorite_cryptos || []
    fav_ids << params[:cryptocurrency_id].to_i unless fav_ids.include?(params[:cryptocurrency_id].to_i)
    current_user.update(favorite_cryptos: fav_ids)
    head :no_content
  end

  # DELETE /api/favorites/:id
  # Удаляет монету из избранного
  def destroy
    fav_ids = current_user.favorite_cryptos || []
    fav_ids.delete(params[:id].to_i)
    current_user.update(favorite_cryptos: fav_ids)
    head :no_content
  end
end
