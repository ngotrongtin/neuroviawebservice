class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :recent, -> { order(created_at: :desc) }

  def admin?
    self.admin
  end

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
end
