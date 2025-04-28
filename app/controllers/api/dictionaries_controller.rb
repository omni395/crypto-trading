# frozen_string_literal: true

class Api::DictionariesController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  # GET /api/dictionaries
  def index
    # Возвращает все возможные значения для справочников
    base_assets = Cryptocurrency.distinct.pluck(:base_asset)
    quote_assets = Cryptocurrency.distinct.pluck(:quote_asset)
    statuses = Cryptocurrency.distinct.pluck(:status)
    market_types = Exchange.active.distinct.pluck(:market_type)
    exchanges = Exchange.active.order(:name).map do |ex|
      {
        name: ex.name,
        slug: ex.slug,
        market_type: ex.market_type,
        price_key: ex.price_key,
        volume_key: ex.volume_key,
        change_key: ex.change_key
      }
    end
    render json: {
      base_assets: base_assets,
      quote_assets: quote_assets,
      statuses: statuses,
      market_types: market_types,
      exchanges: exchanges
    }
  end

  # PATCH/POST /api/dictionaries (опционально, для будущего масштабирования)
  # def update
  #   # Реализация для админки/редактирования справочников
  # end
end
