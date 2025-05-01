class AddChartUrlToExchanges < ActiveRecord::Migration[8.0]
  def change
    add_column :exchanges, :chart_url, :string
  end
end
