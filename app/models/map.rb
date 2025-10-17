class Map < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User'
  has_many :places, dependent: :destroy
  has_many :map_tags, dependent: :destroy
  has_many :tags, through: :map_tags

  # Enums
  enum :privacy, { public: 0, private: 1, shared: 2 }

  # Validations
  validates :title, presence: true

  # Scopes
  scope :public_maps, -> { where(privacy: :public) }
  scope :recent, -> { order(created_at: :desc) }
end
