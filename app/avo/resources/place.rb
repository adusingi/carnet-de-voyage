class Avo::Resources::Place < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :name, as: :text
    field :latitude, as: :number
    field :longitude, as: :number
    field :address, as: :text
    field :place_type, as: :text
    field :emoji, as: :text
    field :context, as: :textarea
    field :position, as: :number
    field :map, as: :belongs_to
  end
end
