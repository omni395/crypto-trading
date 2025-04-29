class RemoveMarketTypeFromCryptocurrencies < ActiveRecord::Migration[7.1]
  def change
    remove_column :cryptocurrencies, :market_type, :string if column_exists?(:cryptocurrencies, :market_type)
    if index_exists?(:cryptocurrencies, [:symbol, :market_type])
      remove_index :cryptocurrencies, column: [:symbol, :market_type]
    end
    add_index :cryptocurrencies, :symbol, unique: true unless index_exists?(:cryptocurrencies, :symbol)
  end
end
