require 'mqtt'
require 'redis'

class MqttSubscriber
  def initialize
    creds = Rails.application.credentials.mqtt || {}
    @host = creds[:host] 
    @port = creds[:port]
    @username = creds[:username]
    @password = creds[:password]
    @topic = creds[:topic] 
    @client_id = creds[:client_id] || "rails_client_#{SecureRandom.hex(4)}"
    @running = false
    # redis for pushing data to Upstash (Redis server)
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
      ssl: @port.to_i == 8883 
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
            # After saved data to the database, pushing message ID to redis server
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
