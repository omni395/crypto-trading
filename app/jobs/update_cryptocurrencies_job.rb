# app/jobs/update_cryptocurrencies_job.rb
class UpdateCryptocurrenciesJob < ApplicationJob
  queue_as :default

  def perform
    BinanceCryptocurrenciesFetcher.fetch_and_update!
  end
end
