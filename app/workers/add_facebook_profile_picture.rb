class AddFacebookProfilePicture
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    facebook_access_token = user.facebook_access_token
    graph = Koala::Facebook::API.new(facebook_access_token, ENV['FACEBOOK_APP_SECRET'])
    picture = graph.get_object('me?fields=picture')
    if picture['picture'] && picture['picture']['data'] && picture['picture']['data']['url']
      picture_url = picture['picture']['data']['url']
    end
    return unless picture_url
    user.photo = URI.parse(picture_url)
    user.save
  end
end
