class CreateMqttMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :mqtt_messages do |t|
      t.string :topic
      t.text :payload
      t.integer :qos
      t.datetime :received_at

      t.timestamps
    end
  end
end
