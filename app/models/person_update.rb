class PersonUpdate < ActiveRecord::Base
  belongs_to :person
  belongs_to :visit

  enum update_type: { created: "created", modified: "modified" }

  validates :person, presence: true
  validates :visit, presence: true
  validates :new_canvass_response, presence: true
  validates :new_party_affiliation, presence: true


  def self.create_for_visit_and_person(visit, person)
    PersonUpdate.create(
      person: person,
      visit: visit,
      update_type: person.new_record? ? :created : :modified,
      old_canvass_response: person.canvass_response_was,
      old_party_affiliation: person.party_affiliation_was,
      new_canvass_response: person.canvass_response,
      new_party_affiliation: person.party_affiliation)
  end
end
