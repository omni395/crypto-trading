class Cryptocurrency < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[
      base_asset created_at data_updated_at id id_value last_price name price_change_percent quote_asset symbol trades updated_at volume
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
