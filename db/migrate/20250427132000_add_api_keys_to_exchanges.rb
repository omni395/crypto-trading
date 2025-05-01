class AddApiKeysToExchanges < ActiveRecord::Migration[8.0]
  def change
    add_column :exchanges, :price_key, :string, default: 'lastPrice', null: false
    add_column :exchanges, :volume_key, :string, default: 'volume', null: false
    add_column :exchanges, :change_key, :string, default: 'priceChangePercent', null: false
  end
end
