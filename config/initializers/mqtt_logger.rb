# config/initializers/mqtt_logger.rb

MQTT_LOGGER = Logger.new(Rails.root.join('log', 'mqtt.log'))
MQTT_LOGGER.level = Logger::INFO
MQTT_LOGGER.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} -- : #{msg}\n"
end
