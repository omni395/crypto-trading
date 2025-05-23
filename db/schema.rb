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

ActiveRecord::Schema[8.0].define(version: 2025_05_08_203252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "exchange", default: "binance", null: false
    t.index ["exchange"], name: "index_cryptocurrencies_on_exchange"
    t.index ["symbol", "exchange"], name: "index_cryptocurrencies_on_symbol_and_exchange", unique: true
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "api_url", null: false
    t.string "status", default: "active", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "batch_api_url"
    t.string "price_key", default: "lastPrice", null: false
    t.string "volume_key", default: "volume", null: false
    t.string "change_key", default: "priceChangePercent", null: false
    t.string "symbol_key", default: "symbol", null: false
    t.string "trades_key", default: "count", null: false
    t.string "chart_url"
    t.string "websocket_url"
    t.jsonb "websocket_klines_format"
    t.jsonb "websocket_klines_mapping"
    t.index ["slug"], name: "index_exchanges_on_slug", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
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

  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
