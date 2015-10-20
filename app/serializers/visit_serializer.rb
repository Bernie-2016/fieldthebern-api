class VisitSerializer < ActiveModel::Serializer
  attributes :total_points, :duration_sec, :created_at

  belongs_to :user
  has_one :address_update
  has_one :address, through: :address_update
  has_many :person_updates
  has_many :people, through: :person_updates
end
