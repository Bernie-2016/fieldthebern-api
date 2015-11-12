class TokensController < Doorkeeper::TokensController
  def create
    if params[:username] == 'facebook'
      user_id = authenticate_with_facebook
    else
      user_id = authenticate_with_credentials
    end

    UpdateUsersLeaderboardsWorker.perform_async(user_id) if user_id

  rescue Doorkeeper::Errors::DoorkeeperError, Doorkeeper::OAuth::Error => e
    handle_token_exception e
    Raven.capture_exception e
  rescue Koala::Facebook::AuthenticationError, ActiveRecord::RecordNotFound => e
    render json: ErrorSerializer.serialize(e), status: 404
  end

  private

    def authenticate_with_facebook
      user_id = get_user_id_from_facebook_information
      token_data = generate_token_data(user_id)
      render json: token_data.to_json, status: :ok

      return user_id
    end

    def get_user_id_from_facebook_information
      facebook_access_token = params[:password]
      graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
      facebook_user = graph.get_object("me", { fields: ['email', 'first_name', 'last_name']})

      User.find_by!(facebook_id: facebook_user["id"]).id
    end

    def generate_token_data(user_id)
      doorkeeper_access_token = Doorkeeper::AccessToken.create!({
        application_id: nil,
        resource_owner_id: user_id,
        expires_in: 7200})

      return {
        access_token: doorkeeper_access_token.token,
        token_type: 'bearer',
        expires_in: doorkeeper_access_token.expires_in,
        user_id: user_id.to_s
      }
    end

    def authenticate_with_credentials
      response = strategy.authorize
      self.headers.merge! response.headers
      self.status = response.status

      user_id = response.try(:token).try(:resource_owner_id)
      body = response.body.merge('user_id' => user_id)
      self.response_body = body.to_json

      return user_id
    end

    def facebook_oauth
      @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'],
                                                     ENV['FACEBOOK_APP_SECRET'],
                                                     ENV['FACEBOOK_REDIRECT_URL'])
    end
end
