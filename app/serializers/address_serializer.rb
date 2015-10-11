class AddressSerializer < ActiveModel::Serializer
  attributes :latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code, :visited_at

  belongs_to :most_supportive_resident
  has_many :people
end
