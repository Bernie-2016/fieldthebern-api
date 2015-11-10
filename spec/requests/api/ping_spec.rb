require 'rails_helper'

describe "Ping API" do
  describe "GET /ping" do

    let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

    it 'gets a pong when pinging' do
      get "#{host}/ping"

      expect(last_response.status).to eq 200
      expect(json.ping).to eq "pong"
    end

    it 'pongs the user email when authed' do
      create(:user, email: "test-user@mail.com", password: "password")

      authenticated_get "ping", nil, token

      expect(last_response.status).to eq 200
      expect(json.ping).to eq "test-user@mail.com"
    end
  end
end
