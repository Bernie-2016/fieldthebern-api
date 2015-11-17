class PersonUpdate < ActiveRecord::Base
  belongs_to :person
  belongs_to :visit

  enum update_type: { created: "created", modified: "modified" }

  validates :person, presence: true
  validates :visit, presence: true
  validates :new_first_name, presence: true
  validates :new_canvass_response, presence: true
  validates :new_party_affiliation, presence: true


  def self.create_for_visit_and_person(visit, person)
    PersonUpdate.create(
      person: person,
      visit: visit,
      update_type: person.new_record? ? :created : :modified,
      old_first_name: person.first_name_was,
      new_first_name: person.first_name,
      old_last_name: person.last_name_was,
      new_last_name: person.last_name,
      old_canvass_response: person.canvass_response_was,
      new_canvass_response: person.canvass_response,
      old_party_affiliation: person.party_affiliation_was,
      new_party_affiliation: person.party_affiliation,
      old_address_id: person.address_id_was,
      new_address_id: person.address_id,
      old_email: person.email_was,
      new_email: person.email,
      old_phone: person.phone_was,
      new_phone: person.phone,
      old_preferred_contact_method: person.preferred_contact_method_was,
      new_preferred_contact_method: person.preferred_contact_method,
      old_previously_participated_in_caucus_or_primary: person.previously_participated_in_caucus_or_primary_was,
      new_previously_participated_in_caucus_or_primary: person.previously_participated_in_caucus_or_primary)
  end
end
