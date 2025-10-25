class MqttMessagesController < ApplicationController
  def index
    @messages = MqttMessage.order(received_at: :desc).page(params[:page]).per(20)

    respond_to do |format|
    format.html
    format.csv do
      headers['Content-Disposition'] = "attachment; filename=\"mqtt_messages_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv\""
      headers['Content-Type'] ||= 'text/csv'
    end
  end
  end

  def show
    @message = MqttMessage.find(params[:id])
    render json: @message
  end
end
