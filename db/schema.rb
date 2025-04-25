# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_04_18_121025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cryptocurrencies", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name"
    t.string "base_asset"
    t.string "quote_asset"
    t.string "status", default: "active", null: false
    t.decimal "min_price_step", precision: 18, scale: 10
    t.decimal "min_qty_step", precision: 18, scale: 10
    t.decimal "commission", precision: 8, scale: 6
    t.string "exchange_url"
    t.string "icon_url"
    t.text "description"
    t.string "market_type", default: "spot", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol", "market_type"], name: "index_cryptocurrencies_on_symbol_and_market_type", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.jsonb "settings", default: "{}", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
