class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :thumb_photo_url,
             :large_photo_url

  def thumb_photo_url
    object.photo.path(:thumb) || User::DEFAULT_THUMB_PHOTO_URL
  end

  def large_photo_url
    object.photo.path(:large) || User::DEFAULT_LARGE_PHOTO_URL
  end
end
