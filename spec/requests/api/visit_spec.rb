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
        create(:user, id: 11, email: "test-user@mail.com", password: "password")
      end

      it 'should return the created visit' do
        address = create(:address, id: 22, latitude: 40.7809482, longitude: -73.2472665)

        authenticated_post "visits", { data: { attributes: {
          duration_sec: 200
        } } }, token

        expect(last_response.status).to eq 200

        visit_json = json.data.attributes

        expect(visit_json.duration_sec).to eq 200
        expect(visit_json.total_points).not_to be_nil
      end

      context 'when address already exists' do
        context 'when person already exists' do
          it 'creates a visit, updates the address and the person'
        end
        context 'when person does not exist' do
          it 'creates a visit, updates the address, creates the person'
        end
      end

      context 'when address doesn\'t already exist' do
        it 'creates a visit as well as an address and the person'
      end
    end
  end
end
