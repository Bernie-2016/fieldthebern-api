require 'rails_helper'

describe 'Address API' do
  describe 'POST /address' do
    it 'requires authentication' do
      post "#{host}/addresses"
      expect(last_response.status).to eq 401
    end

    context 'when authenticated' do
      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      it 'creates an address' do
        authenticated_post "addresses", {
          latitude: 41.233,
          longitude: 42.233,
          street_1: 'A street',
          street_2: 'Something special',
          city: 'Testtown',
          state_code: 'TT',
          zip_code: '1ABCDE',
          result: 'not_home',
        }, token

        expect(last_response.status).to eq 200

        new_address = Address.last

        expect(new_address.persisted?).to be true

        expect(new_address.latitude).to eq 41.233
        expect(new_address.longitude).to eq 42.233
        expect(new_address.street_1).to eq 'A street'
        expect(new_address.street_2).to eq 'Something special'
        expect(new_address.city).to eq 'Testtown'
        expect(new_address.state_code).to eq 'TT'
        expect(new_address.zip_code).to eq '1ABCDE'
        expect(new_address.not_home?).to be true
      end
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
        create(:address, latitude: 1, longitude: 1)
        create(:address, latitude: -1, longitude: -1)
        create(:address, latitude: -1, longitude: 1)
        create(:address, latitude: 1, longitude: -1)
        create(:address, latitude: 20, longitude: 20)

        authenticated_get "addresses", {
          latitude: 0,
          longitude: 0,
          radius: 200 * 1000
        }, token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 4
      end
    end
  end
end
