# app/jobs/update_cryptocurrencies_job.rb
class UpdateCryptocurrenciesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    BinanceSpotCryptocurrenciesFetcher.fetch_and_update!
    BinanceFuturesCryptocurrenciesFetcher.fetch_and_update!
  end
end
