namespace :cryptocurrencies do
  desc "Обновить монеты с Binance (через сервис BinanceSpotCryptocurrenciesFetcher)"
  task refresh: :environment do
    puts "[CRON] Запуск обновления монет с Binance..."
    BinanceSpotCryptocurrenciesFetcher.fetch_and_update!
    BinanceFuturesCryptocurrenciesFetcher.fetch_and_update!
    puts "[CRON] Обновление монет завершено."
  end
end
