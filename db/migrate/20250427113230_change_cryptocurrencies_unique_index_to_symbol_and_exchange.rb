class ChangeCryptocurrenciesUniqueIndexToSymbolAndExchange < ActiveRecord::Migration[8.0]
  def change
    remove_index :cryptocurrencies, :symbol if index_exists?(:cryptocurrencies, :symbol)
    add_index :cryptocurrencies, [:symbol, :exchange], unique: true
  end
end
