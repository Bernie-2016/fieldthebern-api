class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name,
    :party_affiliation, :canvas_response, :created_at, :updated_at

  belongs_to :address
end
