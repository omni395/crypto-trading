class CreateRolesAndUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end

    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end

    add_index :roles, :name, unique: true
    add_index :user_roles, [:user_id, :role_id], unique: true
  end
end
