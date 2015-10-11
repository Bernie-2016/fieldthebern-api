class VisitSerializer < ActiveModel::Serializer
  attributes :total_points, :duration_sec

  belongs_to :user
  belongs_to :address
  has_many :people, through: :address
end
