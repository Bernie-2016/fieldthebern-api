class AddFacebookProfilePicture
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    photo_url = facebook_photo_url(user) unless user.photo.path

    if photo_url
      user.photo = URI.parse(photo_url)
      user.save
    end
  end

  private
    def facebook_photo_url(user)
      facebook_access_token = user.facebook_access_token
      graph = Koala::Facebook::API.new(facebook_access_token, ENV['FACEBOOK_APP_SECRET'])
      picture = graph.get_object('me?fields=picture')
      picture_url = picture['picture'].try(:[], 'data').try(:[], 'url')
      picture_url
    end
end
