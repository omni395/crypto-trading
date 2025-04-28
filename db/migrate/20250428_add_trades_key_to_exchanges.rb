class AddTradesKeyToExchanges < ActiveRecord::Migration[7.1]
  def change
    add_column :exchanges, :trades_key, :string, default: 'count', null: false
  end
end
