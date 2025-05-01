class AddSymbolKeyToExchanges < ActiveRecord::Migration[8.0]
  def change
    add_column :exchanges, :symbol_key, :string, default: 'symbol', null: false
  end
end