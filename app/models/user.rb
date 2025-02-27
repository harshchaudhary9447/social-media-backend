class User < ApplicationRecord
  rolify # Enable role management

  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Set default role after user creation
  after_create :assign_default_role

  def assign_default_role
    self.add_role(:normal) if self.roles.blank? # Every new user gets the 'normal' role
  end

  validates :email, uniqueness: true, presence: true
  validates :phone_number, uniqueness: true, presence: true,
                           format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
end
