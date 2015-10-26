class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :state_code, :visits_count,
    :total_points, :photo_thumb_url, :photo_large_url, :lat, :lng

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
