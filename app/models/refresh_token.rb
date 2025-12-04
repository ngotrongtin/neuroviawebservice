require "digest"

class RefreshToken < ApplicationRecord
  belongs_to :user

  TOKEN_LENGTH = 64

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  def self.generate_raw
    SecureRandom.urlsafe_base64(TOKEN_LENGTH)
  end

  def self.digest(raw)
    Digest::SHA256.hexdigest(raw)
  end

  # Returns [record, raw_token]
  def self.create_for(user:, expires_in: 30.days, ip: nil, user_agent: nil)
    raw = generate_raw
    rec = create!(
      user: user,
      token_digest: digest(raw),
      jti: SecureRandom.uuid,
      expires_at: Time.current + expires_in,
      ip: ip,
      user_agent: user_agent
    )
    [rec, raw]
  end

  def active?
    revoked_at.nil? && expires_at > Time.current
  end

  def revoke!(replaced_by: nil)
    update!(revoked_at: Time.current, replaced_by_jti: replaced_by)
  end

  def self.authenticate(raw_token)
    return nil if raw_token.blank?
    find_by(token_digest: digest(raw_token))
  end

  def self.cleanup_expired!
    where('expires_at <= ?', Time.current).delete_all
  end
end
