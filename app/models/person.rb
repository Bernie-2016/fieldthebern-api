class Person < ActiveRecord::Base
  belongs_to :address

  enum canvas_response: {
    unknown: 'Unknown',
    strongly_for: 'Strongly for',
    leaning_for: 'Leaning for',
    undecided: 'Undecided',
    leaning_against: 'Leaning against',
    strongly_against: 'Strongly against'
  }

  enum party_affiliation: {
    unknown_affiliation: 'Unknown',
    democrat_affiliation: 'Democrat',
    republican_affiliation: 'Republican',
    undeclared_affiliation: 'Undeclared',
    independent_affiliation: 'Independent'
  }
end
