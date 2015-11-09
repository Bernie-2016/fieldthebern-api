class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name,
    :party_affiliation, :canvas_response,
    :phone, :email, :preferred_contact_method

  belongs_to :address
end
