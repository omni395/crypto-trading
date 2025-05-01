class RemoveMarketTypeFromExchanges < ActiveRecord::Migration[8.0]
  def change
    remove_column :exchanges, :market_type, :string
  end
end
