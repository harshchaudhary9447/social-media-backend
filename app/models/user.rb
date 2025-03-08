class User < ApplicationRecord
  rolify
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy


  # after_create :send_welcome_email, :assign_default_role

  def assign_default_role
    self.add_role(:normal) if self.roles.blank?
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end

# validates :email, uniqueness: true, presence: true
# validates :phone_number, uniqueness: true, presence: true,
#                          format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
