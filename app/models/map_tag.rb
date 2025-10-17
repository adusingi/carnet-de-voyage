class MapTag < ApplicationRecord
  # Associations
  belongs_to :map
  belongs_to :tag, counter_cache: :maps_count

  # Validations
  validates :map_id, uniqueness: { scope: :tag_id }
end
