class Cryptocurrency < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[
      base_asset created_at data_updated_at id id_value last_price name price_change_percent quote_asset symbol trades updated_at volume
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.quote_assets_list(market_type = nil)
    key = "quote_assets_list:#{market_type || 'all'}"
    Rails.cache.fetch(key, expires_in: 10.minutes) do
      scope = market_type.present? ? where(market_type: market_type) : all
      scope.distinct.pluck(:quote_asset)
    end
  end

  def self.statuses_list(market_type = nil)
    key = "statuses_list:#{market_type || 'all'}"
    Rails.cache.fetch(key, expires_in: 10.minutes) do
      scope = market_type.present? ? where(market_type: market_type) : all
      scope.distinct.pluck(:status)
    end
  end

  def self.market_types_list
    Rails.cache.fetch("market_types_list", expires_in: 10.minutes) do
      distinct.pluck(:market_type)
    end
  end
end
