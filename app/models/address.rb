class Address < ActiveRecord::Base
  has_many :people
  belongs_to :most_supportive_resident, class_name: 'Person'

  acts_as_mappable :default_units => :meters,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  enum best_canvas_response: {
    unknown: 'Unknown',
    strongly_for: 'Strongly for',
    leaning_for: 'Leaning for',
    undecided: 'Undecided',
    leaning_against: 'Leaning against',
    strongly_against: 'Strongly against',
    not_yet_visited: 'Not yet visited',
    not_home: "Not home"
  }
end
