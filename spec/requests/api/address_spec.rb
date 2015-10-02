require 'rails_helper'

# Used temporarily for performance measurements. Will be removed
require 'time'
def measure(pass = 0)
  start_time = Time.now
  if pass == 0
    yield
  else
    pass.times {|current| result = yield(current)}
  end
  (Time.now - start_time) / (pass == 0 ? 1 : pass)
end

describe 'Address API' do
  describe 'POST /address' do
    it 'requires authentication' do
      post "#{host}/addresses"
      expect(last_response.status).to eq 401
    end
  end

  describe 'GET /address' do
    it 'requires authentication' do
      get "#{host}/addresses"
      expect(last_response.status).to eq 401
    end

    context 'when authenticated' do

      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      it 'requires latitude, longitude and radius as parameters' do

        expect{ authenticated_get "addresses", {}, token }.to raise_error ActionController::ParameterMissing

        expect{ authenticated_get "addresses", {
          latitude: 41.233
        }, token }.to raise_error ActionController::ParameterMissing

        expect{ authenticated_get "addresses", {
          latitude: 41.233,
          longitude: 42.233
        }, token }.to raise_error ActionController::ParameterMissing

        expect{ authenticated_get "addresses", {
          latitude: 41.233,
          longitude: 42.233,
          radius: 200 * 1000
        }, token }.not_to raise_error
      end

      it 'returns a list of addresses within the specified radius of the specified point' do
        create(:address, coordinates: 'POINT(1 1)')
        create(:address, coordinates: 'POINT(-1 -1)')
        create(:address, coordinates: 'POINT(2 -2)')
        create(:address, coordinates: 'POINT(-2 2)')
        create(:address, coordinates: 'POINT(20 20)')


        # puts measure {
        #   for i in 0..20000
        #     create(:address, coordinates: "POINT(1 #{1 + i * 0.001})")
        #   end
        # }

        # puts measure {
        #   authenticated_get "addresses", {
        #     latitude: 0,
        #     longitude: 0,
        #     radius: 200 * 1000
        #   }, token
        # }

        authenticated_get "addresses", {
          latitude: 0,
          longitude: 0,
          radius: 200 * 1000
        }, token

        expect(last_response.status).to eq 200
      end
    end
  end
end
