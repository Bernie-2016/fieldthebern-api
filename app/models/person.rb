class Person < ActiveRecord::Base
  belongs_to :address

  enum canvas_response: {
    unknown: "Unknown",
    strongly_for: "Strongly for",
    leaning_for: "Leaning for",
    undecided: "Undecided",
    leaning_against: "Leaning against",
    strongly_against: "Strongly against"
  }

  enum party_affiliation: {
    unknown_affiliation: "Unknown",
    democrat_affiliation: "Democrat",
    republican_affiliation: "Republican",
    undeclared_affiliation: "Undeclared",
    independent_affiliation: "Independent"
  }

  def canvas_response_rating
    if strongly_against?
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
