require 'mqtt'
require 'redis'

class MqttSubscriber
  RECONNECT_INTERVAL = 5 # seconds

  def initialize
    creds = Rails.application.credentials.mqtt || {}
    @host       = creds[:host]
    @port       = creds[:port]
    @username   = creds[:username]
    @password   = creds[:password]
    @topic      = creds[:topic]
    @client_id  = creds[:client_id] || "rails_client_#{SecureRandom.hex(4)}"
    @running    = false
    @redis      = Redis.new(url: Rails.application.credentials.redis_url)
  end

  def run
    @running = true
    MQTT_LOGGER.info("[MQTT] Starting subscriber for #{@topic} on #{@host}:#{@port}")

    while @running
      begin
        MQTT_LOGGER.info("[MQTT] Connecting as #{@client_id}…")
        MQTT::Client.connect(
          host: @host,
          port: @port,
          username: @username,
          password: @password,
          client_id: @client_id,
          ssl: @port.to_i == 8883
        ) do |client|

          client.subscribe(@topic)
          MQTT_LOGGER.info("[MQTT] Subscribed to #{@topic}")
          
          loop do
            packet = client.get_packet
            next unless packet.is_a?(MQTT::Packet::Publish)

            topic   = packet.topic
            message = packet.payload
            # qos     = packet.qos || 0
            # retain  = packet.retain

            MQTT_LOGGER.info("[MQTT] Received #{topic}: #{message} (QoS=#{packet.qos})")

            process_message(topic, message)
          end
        end

      rescue MQTT::ProtocolException, Errno::ECONNREFUSED, IOError => e
        MQTT_LOGGER.error("[MQTT] Connection lost (#{e.class}: #{e.message}), retrying in #{RECONNECT_INTERVAL}s…")
        sleep RECONNECT_INTERVAL
      rescue => e
        MQTT_LOGGER.error("[MQTT] Unexpected error: #{e.class} #{e.message}")
        MQTT_LOGGER.error(e.backtrace.first(5).join("\n"))
        sleep RECONNECT_INTERVAL
      end
    end

    MQTT_LOGGER.info("[MQTT] Subscriber stopped.")
  end

  def stop
    MQTT_LOGGER.info("[MQTT] Stopping subscriber…")
    @running = false
  end

  private

  def process_message(topic, message)
    msg = MqttMessage.create!(
      topic: topic,
      payload: message.to_s,
      received_at: Time.current
    )

    MQTT_LOGGER.info("[MQTT] Saved message #{msg.id}, broadcasting via Redis…")
    @redis.publish('mqtt_notifications', msg.id.to_s)

  rescue => e
    MQTT_LOGGER.error("[MQTT] Failed to process message: #{e.class} #{e.message}")
  end
end
