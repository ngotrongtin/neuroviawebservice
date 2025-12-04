require 'redis'

Thread.new do
  loop do
    begin
      redis = Redis.new(url: Rails.application.credentials.redis_url)
      Rails.logger.info "[Redis] Subscriber connected"

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
            Rails.logger.warn "[Redis] No message record found"
          end
        end
      end

    rescue Redis::BaseConnectionError, IOError, EOFError => e
      Rails.logger.error "[Redis] Connection lost: #{e.class} - #{e.message}"
      Rails.logger.info "[Redis] Reconnecting in 3s..."
      sleep 3
      retry

    rescue => e
      Rails.logger.error "[Redis] Unexpected error: #{e.class} - #{e.message}"
      Rails.logger.info "[Redis] Retrying in 3s..."
      sleep 3
      retry
    end
  end
end
