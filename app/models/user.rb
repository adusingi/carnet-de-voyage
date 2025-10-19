class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :maps, foreign_key: :creator_id, dependent: :destroy

  # Enums
  enum :role, { free: 0, paid: 1, b2b: 2, admin: 3 }

  # Validations
  validates :username, presence: true, uniqueness: true

  # Methods
  def can_create_map?
    admin? || b2b? || paid? || maps.count < maps_limit
  end

  def admin?
    role == 'admin'
  end
end
