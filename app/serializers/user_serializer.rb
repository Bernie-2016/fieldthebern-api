class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :photo_thumb_url,
             :photo_large_url

  def photo_thumb_url
    object.photo.url(:thumb)
  end

  def photo_large_url
    object.photo.url(:large)
  end
end
