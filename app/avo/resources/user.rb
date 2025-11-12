class Avo::Resources::User < Avo::BaseResource
  self.title = :username
  self.includes = [:maps]

  self.search = {
    query: -> { query.where("username ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :username, as: :text, required: true, sortable: true
    field :email, as: :text, required: true, sortable: true
    field :role, as: :select, enum: ::User.roles, display_value: true, filterable: true
    field :maps_limit, as: :number, default: 5
    field :created_at, as: :date_time, readonly: true, sortable: true
    field :maps, as: :has_many
  end
end
