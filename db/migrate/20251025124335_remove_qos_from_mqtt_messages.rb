class RemoveQosFromMqttMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :mqtt_messages, :qos, :integer
  end
end
