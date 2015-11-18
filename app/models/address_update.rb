class AddressUpdate < ActiveRecord::Base
  belongs_to :address
  belongs_to :visit

  enum update_type: { created: "created", modified: "modified" }

  validates :address, presence: true
  validates :visit, presence: true

  def self.create_for_visit_and_address(visit, address)
    AddressUpdate.create(
      address: address,
      visit: visit,
      update_type: address.new_record? ? :created : :modified,
      old_latitude: address.latitude_was,
      new_latitude: address.latitude,
      old_longitude: address.longitude_was,
      new_longitude: address.longitude,
      old_street_1: address.street_1_was,
      new_street_1: address.street_1,
      old_street_2: address.street_2_was,
      new_street_2: address.street_2,
      old_city: address.city_was,
      new_city: address.city,
      old_state_code: address.state_code_was,
      new_state_code: address.state_code,
      old_zip_code: address.zip_code_was,
      new_zip_code: address.zip_code,
      old_visited_at: address.visited_at_was,
      new_visited_at: address.visited_at,
      old_most_supportive_resident_id: address.most_supportive_resident_id_was,
      new_most_supportive_resident_id: address.most_supportive_resident_id,
      old_best_canvass_response: address.best_canvass_response_was,
      new_best_canvass_response: address.best_canvass_response)
  end
end
