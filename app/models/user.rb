class User < ApplicationRecord
  attr_accessor :remember_token

  before_save {email.downcase!}

  validates :name, presence: true, length: {maximum: Settings.username.maximum}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: Settings.email.maximum},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length:
    {minimum: Settings.password.minimum}, allow_nil: true

  has_secure_password


  class << self
    def digest string
      if cost = ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end

      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end
end
