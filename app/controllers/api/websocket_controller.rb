class Api::WebsocketController < ApplicationController
  def connect
    # Получаем параметры из тела запроса
    request_params = JSON.parse(request.body.read)
    
    exchange = Exchange.find_by!(slug: request_params['exchange'])
    symbol = request_params['symbol']
    interval = request_params['interval']

    # Инициализируем WebSocket соединение
    ws_service = WebsocketService.new(exchange)
    
    # Подписываемся на обновления
    ws_service.subscribe(symbol, interval) do |message|
      # Отправляем данные через ActionCable
      ActionCable.server.broadcast(
        "chart_#{symbol}_#{interval}",
        message
      )
    end

    head :ok
  rescue JSON::ParserError
    render json: { error: 'Invalid JSON' }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Exchange not found' }, status: :not_found
  end
end
