class AddFacebookProfilePicture
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    facebook_access_token = user.facebook_access_token
    graph = Koala::Facebook::API.new(facebook_access_token, ENV['FACEBOOK_APP_SECRET'])
    picture_url = graph.get_picture('me', type: "original")
    return unless picture_url
    user.photo = URI.parse(picture_url)
    user.save
  end
end
