class Person < ActiveRecord::Base
  belongs_to :address
  validates :phone, phone: { possible: true, allow_blank: true }
  validates :email, email: true, allow_blank: true

  enum canvass_response: {
    unknown: "unknown",
    strongly_for: "strongly_for",
    leaning_for: "leaning_for",
    undecided: "undecided",
    leaning_against: "leaning_against",
    strongly_against: "strongly_against",
    asked_to_leave: "asked_to_leave"
  }

  enum party_affiliation: {
    unknown_affiliation: "Unknown",
    democrat_affiliation: "Democrat",
    republican_affiliation: "Republican",
    undeclared_affiliation: "Undeclared",
    independent_affiliation: "Independent",
    other_affiliation: "Other"
  }

  enum preferred_contact_method: {
    contact_by_phone: "phone",
    contact_by_email: "email"
  }

  def canvass_response_rating
    if asked_to_leave?
      return -1
    elsif strongly_against?
      return 0
    elsif leaning_against?
      return 1
    elsif undecided? || unknown?
      return 2
    elsif leaning_for?
      return 3
    elsif strongly_for?
      return 5
    end
  end

  def more_supportive_than? other_person
    self.canvass_response_rating > other_person.canvass_response_rating
  end

  def self.new_or_existing_from_params(params)
    person_id = params.fetch(:id, nil)
    if person_id
      person = Person.find(person_id)
      person.assign_attributes(params)
    else
      person = Person.new(params)
    end

    person
  end
end
