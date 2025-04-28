class AddSymbolKeyToExchanges < ActiveRecord::Migration[7.1]
  def change
    add_column :exchanges, :symbol_key, :string, default: 'symbol', null: false
  end
end