class PersonUpdate < ActiveRecord::Base
  belongs_to :person
  belongs_to :visit

  enum update_type: { created: "created", modified: "modified" }

  validates :person, presence: true
  validates :visit, presence: true
  validates :new_canvas_response, presence: true
  validates :new_party_affiliation, presence: true
end
