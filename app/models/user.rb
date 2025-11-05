class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :recent, -> { order(created_at: :desc) }

  def admin?
    self.admin
  end

  # Search user by fullname or email
  def self.search(fullname: nil, email: nil)
    scope = recent

    if fullname.present?
      escaped = ActiveRecord::Base.sanitize_sql_like(fullname.to_s.strip[0, 200])
      scope = scope.where("fullname ILIKE ?", "%#{escaped}%")
    end

    if email.present?
      escaped = ActiveRecord::Base.sanitize_sql_like(email.to_s.strip[0, 200])
      scope = scope.where("email ILIKE ?", "%#{escaped}%")
    end

    scope
  end

  # Override Devise method to return token
  def send_reset_password_instructions
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw # return raw token for controller to send in email
  end
end
