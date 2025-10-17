class Avo::Resources::Map < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :title, as: :text
    field :description, as: :textarea
    field :destination, as: :text
    field :privacy, as: :number
    field :places_count, as: :number
    field :original_text, as: :textarea
    field :processed_text, as: :textarea
    field :creator, as: :belongs_to
  end
end
