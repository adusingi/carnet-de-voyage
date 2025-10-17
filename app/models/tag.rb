class Tag < ApplicationRecord
  # Associations
  has_many :map_tags, dependent: :destroy
  has_many :maps, through: :map_tags

  # Validations
  validates :name, presence: true, uniqueness: true
end
