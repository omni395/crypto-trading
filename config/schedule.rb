# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"
set :environment, ENV['RAILS_ENV'] || 'development'

# Задача: обновлять монеты с Binance каждые 5 минут
# Предполагается, что UpdateCryptocurrenciesJob уже реализован и вызывает BinanceCryptocurrenciesFetcher

every 5.minutes do
  rake "cryptocurrencies:refresh"
end
