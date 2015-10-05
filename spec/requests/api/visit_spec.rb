require 'rails_helper'

describe 'Visit API' do
  describe 'POST /visits' do
    it 'requires authentication' do
      post "#{host}/visits"
      expect(last_response.status).to eq 401
    end

    context 'when authenticated' do
      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      context 'when address already exists' do
        it 'creates a visit and updates the address'
      end

      context 'when address doesn\'t already exist' do
        it 'creates a visit as well as an address'
      end
    end
  end
end
