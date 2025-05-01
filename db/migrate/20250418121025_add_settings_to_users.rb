class AddSettingsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :settings, :jsonb, null: false, default: '{}'
  end
end
