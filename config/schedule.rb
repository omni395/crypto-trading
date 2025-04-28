# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"
set :environment, ENV['RAILS_ENV'] || 'development'

# Задача: обновлять монеты с Binance каждые 15 минут
# Предполагается, что UpdateCryptocurrenciesJob уже реализован и вызывает BinanceSpotCryptocurrenciesFetcher

every 15.minutes do
  rake "cryptocurrencies:refresh"
end
