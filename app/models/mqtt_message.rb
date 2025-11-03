class MqttMessage < ApplicationRecord
  
  scope :recent, -> { order(received_at: :desc) }

  # search query, if no match, return all
  def self.search(topic: nil, payload: nil)
    scope = recent

    if topic.present?
      escaped_topic = ActiveRecord::Base.sanitize_sql_like(topic.to_s.strip[0, 200])
      scope = scope.where("topic ILIKE ?", "%#{escaped_topic}%")
    end

    if payload.present?
      escaped_payload = ActiveRecord::Base.sanitize_sql_like(payload.to_s.strip[0, 200])
      scope = scope.where("payload ILIKE ?", "%#{escaped_payload}%")
    end

    scope
  end
end
