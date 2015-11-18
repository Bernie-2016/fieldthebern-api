require "ground_game/easypost_helper"
require "ground_game/errors/visit_not_allowed"
require "ground_game/errors/invalid_best_canvass_response"

class Address < ActiveRecord::Base
  has_many :people
  belongs_to :most_supportive_resident, class_name: "Person"

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
    current_most_supportive_resident = self.most_supportive_resident
    there_is_no_current_most_supportive_resident = current_most_supportive_resident.nil?

    if there_is_no_current_most_supportive_resident or person.more_supportive_than? current_most_supportive_resident
      self.most_supportive_resident = person
      self.best_canvass_response = person.canvass_response
    end
  end

  def recently_visited?
    minimum_timespan_hours = (ENV["MIN_INTERVAL_BETWEEN_VISITS_HOURS"] || 1).to_i.hours
    lower_bound = (DateTime.now - minimum_timespan_hours).to_i
    upper_bound = DateTime.now.to_i
    invalid_interval = lower_bound..upper_bound
    invalid_interval.include? self.visited_at.to_i
  end

  def ensure_not_recently_visited!
    raise GroundGame::VisitNotAllowed if self.persisted? and self.recently_visited?
  end

  def assign_last_canvass_response(params)
    self.last_canvass_response = params[:best_canvass_response] if params[:best_canvass_response].present?
    self.last_canvass_response = params[:last_canvass_response] if params[:last_canvass_response].present?
  end

  def self.new_or_existing_from_params(params)
    address_id = params.fetch(:id, nil)

    if address_id.nil?
      address = Address.new
    else
      address = Address.find(address_id)
    end

    address.ensure_not_recently_visited!

    params = GroundGame::EasyPostHelper.extend_address_params_with_usps(params) if address.new_record?

    ensure_best_canvas_response_valid!(params)

    address.assign_attributes(params)
    address.assign_last_canvass_response(params)

    address
  end

  private

    def self.ensure_best_canvas_response_valid!(params)
      canvass_response = params[:best_canvass_response]

      if not best_canvass_response_valid?(canvass_response)
        raise GroundGame::InvalidBestCanvassResponse.new(canvass_response)
      end
    end

    def self.best_canvass_response_valid?(value)
      value.nil? or allowed_best_canvass_responses_for_setting_directly.include? value.to_sym
    end

    def self.allowed_best_canvass_responses_for_setting_directly
      [:asked_to_leave, :not_yet_visited, :not_home]
    end
end
