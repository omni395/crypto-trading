class ChartChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "ChartChannel subscribed: symbol=#{params[:symbol]}, interval=#{params[:interval]}"
    stream_from "chart_#{params[:symbol]}_#{params[:interval]}"
  end

  def unsubscribed
    Rails.logger.info "ChartChannel unsubscribed: symbol=#{params[:symbol]}, interval=#{params[:interval]}"
    stop_all_streams
  end
end
