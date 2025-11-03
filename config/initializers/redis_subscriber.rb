require 'redis'

Thread.new do
  redis = Redis.new(url: Rails.application.credentials.redis_url)

  redis.subscribe('mqtt_notifications') do |on|
    on.message do |channel, message|
      Rails.logger.info "[Redis] Received on #{channel}: #{message}"

      message_record = MqttMessage.order(received_at: :desc).first

      if message_record
        Turbo::StreamsChannel.broadcast_prepend_to(
          "mqtt_messages",
          target: "messages",
          partial: "admin/iot/mqtt_monitor/message",
          locals: { message: message_record }
        )
        Rails.logger.info "[Redis] Broadcasted message #{message_record.id}"
      else
        Rails.logger.warn "[Redis] No message record found to broadcast"
      end
    end
  end
end
