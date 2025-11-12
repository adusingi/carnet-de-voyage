class Avo::Resources::Map < Avo::BaseResource
  self.title = :title
  self.includes = [:creator, :places, :tags]
  self.default_view_type = :table

  self.search = {
    query: -> { query.where("title ILIKE ? OR destination ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :title, as: :text, required: true, sortable: true
    field :destination, as: :text, sortable: true, help: "Main destination city/country"
    field :privacy, as: :select, enum: ::Map.privacies, display_value: true, filterable: true
    field :creator, as: :belongs_to, searchable: true, sortable: true
    field :places_count, as: :number, readonly: true, sortable: true
    field :description, as: :textarea, rows: 3
    field :original_text, as: :textarea, rows: 5, help: "Raw travel notes"
    field :processed_text, as: :textarea, rows: 5, help: "Highlighted version", hide_on: [:index]
    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: [:index]
    field :places, as: :has_many
    field :tags, as: :has_many
  end
end
