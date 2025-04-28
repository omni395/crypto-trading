class AddBatchApiUrlToExchanges < ActiveRecord::Migration[7.0]
  def change
    add_column :exchanges, :batch_api_url, :string
  end
end