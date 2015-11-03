require "ground_game/easypost_helper"

class Address < ActiveRecord::Base
  has_many :people
  belongs_to :most_supportive_resident, class_name: "Person"

  acts_as_mappable :default_units => :meters,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  enum best_canvas_response: {
    asked_to_leave: "Asked to leave",
    unknown: "Unknown",
    strongly_for: "Strongly for",
    leaning_for: "Leaning for",
    undecided: "Undecided",
    leaning_against: "Leaning against",
    strongly_against: "Strongly against",
    not_yet_visited: "Not yet visited",
    not_home: "Not home"
  }


  def assign_most_supportive_resident(person)
    current_resident = self.most_supportive_resident
    there_is_no_current_resident = current_resident.nil?

    if there_is_no_current_resident or person.more_supportive_than? current_resident
      self.most_supportive_resident = person
      self.best_canvas_response = person.canvas_response
    end
  end

  def self.new_or_existing_from_params(params)
    address_id = params.fetch(:id, nil)

    if address_id
      address = existing_with_params(address_id, params)
    else
      address = new_from_params(params)
    end

    address
  end

  private

  def self.new_from_params(params)
    params = GroundGame::EasyPostHelper.extend_address_params_with_usps(params)
    Address.new(params)
  end

  def self.existing_with_params(id, params)
    address = Address.find(id)
    if best_canvas_response_value_valid(params[:best_canvas_response])
      address.assign_attributes(params)
      return address
    else
      raise ArgumentError.new("Invalid argument #{params[:best_canvas_response]} for address.best_canvas_response")
    end
  end

  def self.best_canvas_response_value_valid(value)
    value.nil? or allowed_best_canvas_response_values_for_setting_directly.include? value.to_sym
  end

  def self.allowed_best_canvas_response_values_for_setting_directly
    [:asked_to_leave, :not_yet_visited, :not_home]
  end
end
