class AddWebsocketFieldsToExchanges < ActiveRecord::Migration[8.0]
  def change
    add_column :exchanges, :websocket_url, :string
  end
end
