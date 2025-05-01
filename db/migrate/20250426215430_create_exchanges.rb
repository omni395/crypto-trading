class CreateExchanges < ActiveRecord::Migration[8.0]
  def change
    create_table :exchanges do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :api_url, null: false
      t.string :status, null: false, default: 'active' # active, disabled
      t.text :description
      t.timestamps
    end
  end
end
