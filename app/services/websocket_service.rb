require 'faye/websocket'
require 'eventmachine'

class WebsocketService
  def initialize(exchange)
    @exchange = exchange
    @ws = nil
    @subscribers = []
  end

  def connect
    return if @ws&.connected?

    EM.run do
      @ws = Faye::WebSocket::Client.new(@exchange.websocket_url)

      @ws.on :open do |event|
        Rails.logger.info "WebSocket соединение установлено для #{@exchange.name}"
        subscribe_to_channels
      end

      @ws.on :message do |event|
        handle_message(event.data)
      end

      @ws.on :close do |event|
        Rails.logger.info "WebSocket соединение закрыто для #{@exchange.name}: #{event.code} #{event.reason}"
        EM.stop
        # Переподключение через 5 секунд
        EM.add_timer(5) { connect }
      end

      @ws.on :error do |event|
        Rails.logger.error "WebSocket ошибка для #{@exchange.name}: #{event.message}"
      end
    end
  end

  def subscribe(symbol, interval, &block)
    @subscribers << { symbol: symbol, interval: interval, callback: block }
    subscribe_to_channel(symbol, interval) if @ws&.connected?
  end

  private

  def subscribe_to_channels
    @subscribers.each do |sub|
      subscribe_to_channel(sub[:symbol], sub[:interval])
    end
  end

  def subscribe_to_channel(symbol, interval)
    # Используем URL из базы, подставляя symbol и interval
    url = @exchange.websocket_url.gsub('%{symbol}', symbol).gsub('%{interval}', interval)
    @ws.send({ method: 'SUBSCRIBE', params: [url], id: 1 }.to_json)
  end

  def handle_message(data)
    message = JSON.parse(data)
    @subscribers.each { |s| s[:callback].call(message) }
  end
end
