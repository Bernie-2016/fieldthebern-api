require 'rails_helper'

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

      it 'requires lattitude and longitude as parameters' do
        create(:user, email: "test-user@mail.com", password: "password")
        expect{ authenticated_get "addresses", {}, token }.to raise_error ActionController::ParameterMissing

        expect{ authenticated_get "addresses", { lattitude: 41.233, longitude: 42.233 }, token }.not_to raise_error
      end
    end
  end
end
