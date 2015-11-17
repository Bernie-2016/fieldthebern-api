class PersonUpdateSerializer < ActiveModel::Serializer
  attributes :id, :update_type, :old_canvass_response, :new_canvass_response,
    :old_party_affiliation, :new_party_affiliation

  belongs_to :person
  belongs_to :visit
end
