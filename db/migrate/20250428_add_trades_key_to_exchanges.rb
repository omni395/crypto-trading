class AddTradesKeyToExchanges < ActiveRecord::Migration[8.0]
  def change
    add_column :exchanges, :trades_key, :string, default: 'count', null: false
  end
end
