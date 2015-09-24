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
end

RSpec.configure do |config|
  config.include RequestHelpers, :type=>:request #apply to all spec for apis folder
end
