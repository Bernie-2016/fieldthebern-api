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

      it 'should return the created visit'

      context 'when address already exists' do
        it 'creates a visit and updates the address' do
          create(:address, latitude: 1, longitude: 1)

          authenticated_post "visits", { data: { attributes: {
            submitted_latitude: 1,
            submitted_longitude: 1,
            submitted_street_1: 'A street',
            submitted_street_2: 'Something special',
            submitted_city: 'Testtown',
            submitted_state_code: 'TT',
            submitted_zip_code: '1ABCDE',
            result: 'not_home',
            duration_sec: 200
          } } }, token

          expect(last_response.status).to eq 200

          new_visit = Visit.last

          expect(new_visit).not_to be_nil
        end
      end

      context 'when address doesn\'t already exist' do
        it 'creates a visit as well as an address'
      end
    end
  end
end
