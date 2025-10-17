class Place < ApplicationRecord
  # Associations
  belongs_to :map, counter_cache: :places_count

  # Validations
  validates :name, presence: true

  # Scopes
  scope :ordered, -> { order(position: :asc) }
end
