class TokensController < Doorkeeper::TokensController
  def create
    if params[:username] == 'facebook'
      find_user_from_facebook_information
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

  def find_user_from_facebook_information
    facebook_access_token = params[:password]
    graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
    facebook_user = graph.get_object("me", { fields: ['email', 'first_name', 'last_name']})

    user = User.where(facebook_id: facebook_user["id"]).first

    if user
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

      UpdateUsersLeaderboardsWorker.perform_async(user.id)

      render json: token_data.to_json, status: :ok
    else
      # indicate no user error here
    end
  end

  def facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'],
                                                   ENV['FACEBOOK_APP_SECRET'],
                                                   ENV['FACEBOOK_REDIRECT_URL'])
  end
end
