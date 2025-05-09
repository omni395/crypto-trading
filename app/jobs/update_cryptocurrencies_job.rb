# app/jobs/update_cryptocurrencies_job.rb
class UpdateCryptocurrenciesJob < ApplicationJob
  queue_as :default

  def perform
    Exchange.active.each do |exchange|
      CryptocurrenciesFetcher.fetch_and_update!(exchange.slug)
    end
  end
end
