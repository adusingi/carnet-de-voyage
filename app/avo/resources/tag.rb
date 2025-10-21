class Avo::Resources::Tag < Avo::BaseResource
  self.title = :name
  self.includes = [:maps]

  self.search = {
    query: -> { query.where("name ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :name, as: :text, required: true, sortable: true
    field :maps_count, as: :number, readonly: true, sortable: true
    field :maps, as: :has_many
    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: [:index]
  end
end
