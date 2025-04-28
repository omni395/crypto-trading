# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# --- Admin user and role seed ---
admin_email = 'admin@example.com'
admin_password = '12345678'
admin_user = User.find_or_create_by!(email: admin_email) do |u|
  u.password = admin_password
  u.password_confirmation = admin_password
end

admin_role = Role.find_or_create_by!(name: 'admin')
UserRole.find_or_create_by!(user: admin_user, role: admin_role)
puts "[SEED] Админ-пользователь: #{admin_email} / #{admin_password} (роль admin)"


# Seed exchanges for initial setup
# Используем find_or_initialize_by + assign_attributes + save! для идемпотентности:
# - Если биржа с таким slug уже есть, её атрибуты будут обновлены (name, api_url и др.)
# - Если нет — создастся новая запись.
# Это позволяет безопасно запускать сиды несколько раз без дублей и с актуализацией данных.
[
  {
    name: 'Binance Spot',
    slug: 'binance_spot',
    api_url: 'https://api.binance.com/api/v3/ticker/24hr?symbol=',
    market_type: 'spot',
    status: 'active',
    description: 'Binance main spot market'
  },
  {
    name: 'Binance Futures',
    slug: 'binance_futures',
    api_url: 'https://fapi.binance.com/fapi/v1/ticker/24hr?symbol=',
    market_type: 'futures',
    status: 'active',
    description: 'Binance main futures market'
  }
  # Добавьте сюда другие биржи по мере необходимости
].each do |attrs|
  exchange = Exchange.find_or_initialize_by(slug: attrs[:slug])
  exchange.assign_attributes(attrs)
  exchange.save!
end
