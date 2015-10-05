class VisitSerializer < ActiveModel::Serializer
  attributes :submitted_latitude, :submitted_longitude, :corrected_latitude, :corrected_longitude,
             :submitted_street_1, :submitted_street_2, :submitted_city, :submitted_state_code, :submitted_zip_code,
             :result, :total_points, :duration_sec

  belongs_to :user
  belongs_to :address

end
