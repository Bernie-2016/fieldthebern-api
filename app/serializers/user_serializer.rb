class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :photo_thumb_url,
             :photo_large_url

  def photo_thumb_url
    object.photo.path ? object.photo.url(:thumb) : User::DEFAULT_PHOTO_THUMB_URL
  end

  def photo_large_url
    object.photo.path ? object.photo.url(:large) : User::DEFAULT_PHOTO_LARGE_URL
  end
end
