class PersonSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name,
    :party_affiliation, :canvas_response, :created_at, :updated_at, :previously_participated_in_caucus_or_primary, :preferred_contact_method

  belongs_to :address

  def preferred_contact_method
  	return "phone" if object.contact_by_phone?
  	return "email" if object.contact_by_email?
  end
end
