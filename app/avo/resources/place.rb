class Avo::Resources::Place < Avo::BaseResource
  self.title = :name
  self.includes = [:map]
  self.default_view_type = :table

  self.search = {
    query: -> { query.where("name ILIKE ? OR address ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :name, as: :text, required: true, sortable: true
    field :emoji, as: :text, help: "Place icon"
    field :place_type, as: :text, sortable: true, help: "e.g. restaurant, hotel, museum"
    field :position, as: :number, sortable: true, help: "Display order"
    field :latitude, as: :number, format_using: -> { value.round(6) if value }
    field :longitude, as: :number, format_using: -> { value.round(6) if value }
    field :address, as: :text
    field :context, as: :textarea, rows: 3, help: "Additional notes from travel text"
    field :map, as: :belongs_to, searchable: true, required: true
    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: [:index]
  end
end
