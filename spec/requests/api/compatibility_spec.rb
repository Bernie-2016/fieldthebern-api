require 'rails_helper'
require 'cgi'

describe "Compatibility API" do

  describe "GET /compatibility" do

    before do
      stub_const('ENV', ENV.to_hash.merge("MIN_COMPATIBLE_APP_VERSION" => "1.2.3"))
    end

    it "returns 'true' if app version is compatible with API version" do
      app_version = CGI.escape("1.2.4")

      get "#{host}/compatibility/", { version: app_version }

      expect(last_response.status).to eq 200
      expect(json.compatible).to be true
    end

    it "returns 'false' if app version is not compatible with API version" do
      app_version = CGI.escape("1.2.2")

      get "#{host}/compatibility/", { version: app_version }

      expect(last_response.status).to eq 200
      expect(json.compatible).to be false
    end
  end
end
