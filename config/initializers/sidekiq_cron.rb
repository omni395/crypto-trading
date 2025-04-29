# Автоматический запуск задачи по обновлению монет с Binance через sidekiq-cron
if defined?(Sidekiq) && Sidekiq.server?
  require 'sidekiq/cron/job'
  Sidekiq::Cron::Job.create(
    name: 'Binance coins sync - every 5min',
    cron: '*/30 * * * *',
    class: 'UpdateCryptocurrenciesJob'
  )
  Sidekiq::Cron::Job.create(
    name: 'Instruments cache sync - every 5min',
    cron: '*/5 * * * *',
    class: 'InstrumentsCacheJob'
  )
end
