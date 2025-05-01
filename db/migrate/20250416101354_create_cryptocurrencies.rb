class CreateCryptocurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :cryptocurrencies do |t|
      t.string :symbol, null: false
      t.string :name
      t.string :base_asset
      t.string :quote_asset
      t.string :status, default: 'active', null: false # active, delisted, etc.
      t.decimal :min_price_step, precision: 18, scale: 10
      t.decimal :min_qty_step, precision: 18, scale: 10
      t.decimal :commission, precision: 8, scale: 6
      t.string :exchange_url
      t.string :icon_url
      t.text :description
      t.timestamps
    end
    remove_index :cryptocurrencies, :symbol if index_exists?(:cryptocurrencies, :symbol)
    add_index :cryptocurrencies, [:symbol], unique: true
  end
end
