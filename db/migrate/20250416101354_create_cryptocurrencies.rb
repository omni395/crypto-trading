class CreateCryptocurrencies < ActiveRecord::Migration[7.1]
  def change
    create_table :cryptocurrencies do |t|
      t.string :symbol
      t.string :name
      t.string :base_asset
      t.string :quote_asset
      t.float :volume
      t.integer :trades
      t.float :price_change_percent
      t.float :last_price
      t.datetime :data_updated_at

      t.timestamps
    end
  end
end
