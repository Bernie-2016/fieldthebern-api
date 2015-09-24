class TokensController < Doorkeeper::TokensController

  def create
    response = strategy.authorize
    user_id = response.try(:token).try(:resource_owner_id)
    if user_id
      user = User.find(user_id)
    end
    self.headers.merge! response.headers
    self.response_body = body.to_json
    self.status = response.status
  rescue Doorkeeper::Errors::DoorkeeperError, Doorkeeper::OAuth::Error => e
    handle_token_exception e
  end

end
