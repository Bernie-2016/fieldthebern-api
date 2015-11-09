class Person < ActiveRecord::Base
  belongs_to :address
  validates :phone, phone: { possible: true, allow_blank: true }
  validates :email, email: true, allow_blank: true

  enum canvas_response: {
    unknown: "Unknown",
    strongly_for: "Strongly for",
    leaning_for: "Leaning for",
    undecided: "Undecided",
    leaning_against: "Leaning against",
    strongly_against: "Strongly against",
    asked_to_leave: "Asked to leave"
  }

  enum party_affiliation: {
    unknown_affiliation: "Unknown",
    democrat_affiliation: "Democrat",
    republican_affiliation: "Republican",
    undeclared_affiliation: "Undeclared",
    independent_affiliation: "Independent"
  }

  enum preferred_contact_method: {
    contact_by_phone: "phone",
    contact_by_email: "email"
  }

  def canvas_response_rating
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
    self.canvas_response_rating > other_person.canvas_response_rating
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
