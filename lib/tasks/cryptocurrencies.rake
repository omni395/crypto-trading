namespace :cryptocurrencies do
  desc "Обновить монеты для всех активных бирж"
  task update: :environment do
    Exchange.active.each do |exchange|
      CryptocurrenciesFetcher.fetch_and_update!(exchange.slug)
    end
  end
end
