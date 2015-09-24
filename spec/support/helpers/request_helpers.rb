require 'json'
require 'hashie/mash'

module RequestHelpers
  def json
    Hashie::Mash.new JSON.parse(last_response.body)
  end
end
