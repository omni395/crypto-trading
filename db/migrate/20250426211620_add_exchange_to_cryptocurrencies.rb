class AddExchangeToCryptocurrencies < ActiveRecord::Migration[7.0]
  def change
    add_column :cryptocurrencies, :exchange, :string, null: false, default: 'binance'
    add_index :cryptocurrencies, :exchange
  end
end
