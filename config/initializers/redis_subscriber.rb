require 'redis'

Thread.new do
  redis = Redis.new(url: Rails.application.credentials.redis_url)

  redis.subscribe('mqtt_notifications') do |on|
    on.message do |channel, message|
      Rails.logger.info "[Redis] Received on #{channel}: #{message}"

      msg = MqttMessage.find_by(id: message)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "mqtt_messages",
        target: "messages",
        partial: "mqtt_messages/message",
        locals: { message: msg } 
      )
    end
  end
end
