require 'json'
require 'hashie/mash'

module RequestHelpers
	include Rack::Test::Methods

  def app
    Rails.application
  end

  def json
    Hashie::Mash.new JSON.parse(last_response.body)
  end

  def authenticate(email:, password:)
    application = create(:oauth_application)

    client = OAuth2::Client.new(application.uid, application.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    access_token = client.password.get_token(email, password)
    access_token.token
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, :type=>:request #apply to all spec for apis folder
end
