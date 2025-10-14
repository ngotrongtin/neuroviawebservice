require 'mqtt'
require 'redis'

class MqttSubscriber
  def initialize
    creds = Rails.application.credentials.mqtt || {}
    @host = creds[:host] || 'broker.hivemq.com'
    @port = creds[:port] || 1883
    @username = creds[:username]
    @password = creds[:password]
    @topic = creds[:topic] || 'home/livingroom/light/#'
    @client_id = creds[:client_id] || "rails_client_#{SecureRandom.hex(4)}"
    @running = false
    @redis = Redis.new(url: Rails.application.credentials.redis_url)
  end

  def run
    @running = true
    MQTT_LOGGER.info("[MQTT] Connecting to #{@host}:#{@port} as #{@client_id}, subscribing to '#{@topic}'")

    MQTT::Client.connect(
      host: @host,
      port: @port,
      username: @username,
      password: @password,
      client_id: @client_id,
      ssl: @port.to_i == 8883 # tự động bật SSL nếu là cổng HiveMQ Cloud
    ) do |client|
      client.get(@topic, subscribe: true) do |topic, message|
        MQTT_LOGGER.info("[MQTT] Received on #{topic} => #{message}")

        begin
            msg = MqttMessage.create!(
              topic: topic,
              payload: message.to_s,
              qos: 0,
              received_at: Time.current
            )
            MQTT_LOGGER.info("[MQTT] Saved message #{msg.id}, broadcasting…")
            @redis.publish('mqtt_notifications', "#{msg.id}")
        rescue => e
          MQTT_LOGGER.error("[MQTT] Failed to save message: #{e.class} #{e.message}")
        end
      end
    end

    @running = false
  rescue Interrupt
    MQTT_LOGGER.error("[MQTT] Interrupted, exiting")
  rescue => e
    MQTT_LOGGER.error("[MQTT] Error: #{e.class} #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    raise
  end

  def stop
    @running = false
  end
end
