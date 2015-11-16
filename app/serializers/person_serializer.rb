class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name,
    :party_affiliation, :canvas_response, :created_at, :updated_at, :previously_participated_in_caucus_or_primary, :preferred_contact_method

  belongs_to :address
end
