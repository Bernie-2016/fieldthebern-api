class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name,
    :party_affiliation, :canvas_response,
    :previously_participated_in_caucus_or_primary,
    :phone, :email, :preferred_contact_method

  belongs_to :address
end
