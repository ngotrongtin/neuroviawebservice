namespace :mqtt do
  desc "Run MQTT subscriber listener"
  task subscribe: :environment do
    MqttSubscriber.new.run
  end
end
