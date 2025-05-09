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
    api_url: 'https://api.binance.com/api/v3/exchangeInfo',
    batch_api_url: 'https://api.binance.com/api/v3/ticker/24hr?symbols=[%{symbols}]',
    chart_url: 'https://api.binance.com/api/v3/klines?symbol=%{symbol}&interval=%{interval}',
    websocket_url: 'wss://stream.binance.com:9443/ws/%{symbol}@kline_%{interval}',
    status: 'active',
    description: 'Binance main spot market',
    price_key: 'lastPrice',
    volume_key: 'volume',
    change_key: 'priceChangePercent',
    symbol_key: 'symbol',
    trades_key: 'count'
  },
  {
    name: 'Binance Futures',
    slug: 'binance_futures',
    api_url: 'https://fapi.binance.com/fapi/v1/exchangeInfo',
    batch_api_url: 'https://fapi.binance.com/fapi/v1/ticker/24hr?symbols=[%{symbols}]',
    chart_url: 'https://fapi.binance.com/fapi/v1/klines?symbol=%{symbol}&interval=%{interval}',
    websocket_url: 'wss://fapi.binance.com/ws/%{symbol}@kline_%{interval}',
    status: 'active',
    description: 'Binance main futures market',
    price_key: 'lastPrice',
    volume_key: 'volume',
    change_key: 'priceChangePercent',
    symbol_key: 'symbol',
    trades_key: 'count'
  }
  # Добавьте сюда другие биржи по мере необходимости
].each do |attrs|
  exchange = Exchange.find_or_initialize_by(slug: attrs[:slug])
  exchange.assign_attributes(attrs)
  exchange.save!
end