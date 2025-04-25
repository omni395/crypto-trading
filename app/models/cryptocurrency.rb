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
    scope = market_type.present? ? where(market_type: market_type) : all
    scope.distinct.pluck(:quote_asset)
  end

  def self.statuses_list(market_type = nil)
    scope = market_type.present? ? where(market_type: market_type) : all
    scope.distinct.pluck(:status)
  end

  def self.market_types_list
    distinct.pluck(:market_type)
  end
end
