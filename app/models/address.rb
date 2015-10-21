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
    address.assign_attributes(params)
    address
  end
end
