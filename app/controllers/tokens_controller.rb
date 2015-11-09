require "ground_game/scenario/update_user_attributes_from_facebook"

class TokensController < Doorkeeper::TokensController
  def create
    if params[:username] == 'facebook'
      find_or_create_user_from_facebook_information
    else
      authorize_user_and_update_leaderboards
    end
  rescue Doorkeeper::Errors::DoorkeeperError, Doorkeeper::OAuth::Error => e
    handle_token_exception e
    Raven.capture_exception e
  end

  private

  def authorize_user_and_update_leaderboards
    response = strategy.authorize
    user_id = response.try(:token).try(:resource_owner_id)
    body = response.body.merge('user_id' => user_id)
    UpdateUsersLeaderboardsWorker.perform_async(user_id) if user_id
    self.headers.merge! response.headers
    self.response_body = body.to_json
    self.status = response.status
  end

  def find_or_create_user_from_facebook_information
    facebook_access_token = params[:password]
    graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
    facebook_user = graph.get_object("me", { fields: ['email', 'first_name', 'last_name']})

    user = User.where("facebook_id = ? OR email = ?", facebook_user["id"], facebook_user["email"]).first_or_create.tap do |u|
      u = GroundGame::Scenario::UpdateUserAttributesFromFacebook.new(u, facebook_user).call
      u.facebook_access_token = facebook_access_token
      u.password = User.friendly_token unless u.encrypted_password.present?
      u.save!
    end

    doorkeeper_access_token =
    Doorkeeper::AccessToken.create!(application_id: nil,
                                    resource_owner_id: user.id,
                                    expires_in: 7200)
    token_data = {
      access_token: doorkeeper_access_token.token,
      token_type: 'bearer',
      expires_in: doorkeeper_access_token.expires_in,
      user_id: user.id.to_s
    }

    InitializeNewFacebookUserWorker.perform_async(user.id)
    AddFacebookProfilePicture.perform_async(user.id) unless user.photo.present?

    render json: token_data.to_json, status: :ok
  end

  def facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'],
                                                   ENV['FACEBOOK_APP_SECRET'],
                                                   ENV['FACEBOOK_REDIRECT_URL'])
  end
end
