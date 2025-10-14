class MqttMessagesController < ApplicationController
  def index
    @messages = MqttMessage.order(received_at: :desc).page(params[:page]).per(20)
  end

  def show
    @message = MqttMessage.find(params[:id])
    render json: @message
  end
end
