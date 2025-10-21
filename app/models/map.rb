class Map < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User'
  has_many :places, dependent: :destroy
  has_many :map_tags, dependent: :destroy
  has_many :tags, through: :map_tags

  # Enums
  enum :privacy, { publicly_visible: 0, privately_visible: 1, shared_with_link: 2 }, prefix: true

  # Validations
  validates :title, presence: true

  # Scopes
  scope :public_maps, -> { where(privacy: :publicly_visible) }
  scope :recent, -> { order(created_at: :desc) }

  # Google Maps URL generation
  def google_maps_url
    GoogleMapsUrlGenerator.new(self).generate_url
  end

  def google_maps_url_with_names
    GoogleMapsUrlGenerator.new(self).generate_url_with_names
  end
end
