class Cryptocurrency < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[
      base_asset created_at data_updated_at id id_value last_price name price_change_percent quote_asset symbol trades updated_at volume
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.quote_assets_list
    Rails.cache.fetch("quote_assets_list:all", expires_in: 10.minutes) do
      all.distinct.pluck(:quote_asset)
    end
  end

  def self.statuses_list
    Rails.cache.fetch("statuses_list:all", expires_in: 10.minutes) do
      all.distinct.pluck(:status)
    end
  end
  
  belongs_to :exchange, foreign_key: 'exchange', primary_key: 'slug', optional: true
end
