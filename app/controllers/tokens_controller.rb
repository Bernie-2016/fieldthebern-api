class TokensController < Doorkeeper::TokensController

  def create
    if params[:facebook_auth_code]
      access_token_info = facebook_oauth.get_access_token_info(params[:facebook_auth_code])
      facebook_access_token = access_token_info["access_token"] || JSON.parse(access_token_info.keys[0])["access_token"]
      graph = Koala::Facebook::API.new(facebook_access_token, ENV["FACEBOOK_APP_SECRET"])
      facebook_user = graph.get_object("me", { fields: 'email, name'})

      user = User.where("facebook_id = ? OR email = ?", facebook_user["id"], facebook_user["email"]).first_or_create.tap do |u|
        u.email = facebook_user["email"] unless u.email.present?
        u.facebook_id = facebook_user["id"]
        u.facebook_access_token = facebook_access_token
        u.password = User.friendly_token unless u.encrypted_password.present?
        u.save!
      end

      AddFacebookFriendsWorker.perform_async(user.id)

      doorkeeper_access_token = Doorkeeper::AccessToken.create!(application_id: nil, resource_owner_id: user.id, expires_in: 7200)

      token_data = {
        access_token: doorkeeper_access_token.token,
        token_type: "bearer",
        expires_in: doorkeeper_access_token.expires_in,
        user_id: user.id.to_s,
      }

      render json: token_data.to_json, status: :ok
    else
      response = strategy.authorize
      user_id = response.try(:token).try(:resource_owner_id)
      body = response.body.merge("user_id" => user_id)
      if user_id
        user = User.find(user_id)
      end
      self.headers.merge! response.headers
      self.response_body = body.to_json
      self.status = response.status
    end
  rescue Doorkeeper::Errors::DoorkeeperError, Doorkeeper::OAuth::Error => e
    handle_token_exception e
  end

  def facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
  end

end
