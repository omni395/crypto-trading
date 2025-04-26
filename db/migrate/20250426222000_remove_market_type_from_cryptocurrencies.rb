class RemoveMarketTypeFromCryptocurrencies < ActiveRecord::Migration[7.1]
  def change
    remove_column :cryptocurrencies, :market_type, :string
    remove_index :cryptocurrencies, column: [:symbol, :market_type] if index_exists?(:cryptocurrencies, [:symbol, :market_type])

    # Удалить дубликаты по symbol, оставить только одну запись для каждого symbol
    execute <<-SQL.squish
      DELETE FROM cryptocurrencies a
      USING cryptocurrencies b
      WHERE a.id < b.id AND a.symbol = b.symbol;
    SQL

    add_index :cryptocurrencies, :symbol, unique: true unless index_exists?(:cryptocurrencies, :symbol)
  end
end
