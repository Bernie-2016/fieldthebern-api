class AddressSerializer < ActiveModel::Serializer
  attributes :latitude, :longitude, :street_1, :street_2, :city, :state_code,
    :zip_code, :visited_at, :best_canvass_response, :last_canvass_response

  belongs_to :most_supportive_resident, serializer: UserSerializerWithoutIncludes
  belongs_to :last_visited_by, serializer: UserSerializerWithoutIncludes
  has_many :people
end
