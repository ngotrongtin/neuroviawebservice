class MqttMessage < ApplicationRecord
  belongs_to :device, optional: true

  scope :recent, -> { order(received_at: :desc) }

  def self.search(topic: nil, payload: nil)
    scope = recent

    if topic.present?
      escaped = ActiveRecord::Base.sanitize_sql_like(topic.to_s.strip[0, 200])
      scope = scope.where("topic ILIKE ?", "%#{escaped}%")
    end

    if payload.present?
      escaped = ActiveRecord::Base.sanitize_sql_like(payload.to_s.strip[0, 200])
      scope = scope.where("payload::text ILIKE ?", "%#{escaped}%")
    end

    scope
  end
end
