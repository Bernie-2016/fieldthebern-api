class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :state_code, :visits_count,
    :total_points
end
