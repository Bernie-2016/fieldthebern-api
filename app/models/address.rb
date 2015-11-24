require "ground_game/easypost_helper"
require "ground_game/errors/visit_not_allowed"

class Address < ActiveRecord::Base
  has_many :people
  belongs_to :most_supportive_resident, class_name: "Person"
  belongs_to :last_visited_by, class_name: "User"

  acts_as_mappable :default_units => :meters,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude



  enum best_canvass_response: {
    best_is_asked_to_leave: "asked_to_leave",
    best_is_unknown: "unknown",
    best_is_strongly_for: "strongly_for",
    best_is_leaning_for: "leaning_for",
    best_is_undecided: "undecided",
    best_is_leaning_against: "leaning_against",
    best_is_strongly_against: "strongly_against",
    best_is_not_yet_visited: "not_yet_visited",
    best_is_not_home: "not_home"
  }

  def best_canvass_response
    self[:best_canvass_response]
  end

  def best_canvass_response_was
    enum_value = self.changed_attributes[:best_canvass_response]
    string_value = Address.best_canvass_responses[enum_value]
    string_value
  end

  enum last_canvass_response: {
    last_is_asked_to_leave: "asked_to_leave",
    last_is_unknown: "unknown",
    last_is_strongly_for: "strongly_for",
    last_is_leaning_for: "leaning_for",
    last_is_undecided: "undecided",
    last_is_leaning_against: "leaning_against",
    last_is_strongly_against: "strongly_against",
    last_is_not_yet_visited: "not_yet_visited",
    last_is_not_home: "not_home"
  }

  def last_canvass_response
    self[:last_canvass_response]
  end

  def last_canvass_response_was
    enum_value = self.changed_attributes[:last_canvass_response]
    string_value = Address.last_canvass_responses[enum_value]
    string_value
  end

  validates :state_code, presence: true

  def assign_most_supportive_resident(person)
    current_best = self.most_supportive_resident

    if current_best.nil? or person.more_supportive_than? current_best
      self.most_supportive_resident = person
    elsif current_best == person
      other_people_at_address = people - [current_best]
      next_best = other_people_at_address.max_by(&:canvass_response_rating)

      self.most_supportive_resident = next_best if next_best.present? and next_best.more_supportive_than? person
    end

    self.best_canvass_response = self.most_supportive_resident.canvass_response
  end

  def recently_visited?
    minimum_timespan_hours = (ENV["MIN_INTERVAL_BETWEEN_VISITS_HOURS"] || 1).to_i.hours
    lower_bound = (DateTime.now - minimum_timespan_hours).to_i
    upper_bound = DateTime.now.to_i
    invalid_interval = lower_bound..upper_bound
    invalid_interval.include? self.visited_at.to_i
  end
end
