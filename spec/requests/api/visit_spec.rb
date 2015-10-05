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
        address = create(:address, id: 22, latitude: 1, longitude: 2)

        authenticated_post "visits", { data: { attributes: {
          submitted_latitude: 1,
          submitted_longitude: 2,
          submitted_street_1: 'A street',
          submitted_street_2: 'Something special',
          submitted_city: 'Testtown',
          submitted_state_code: 'TT',
          submitted_zip_code: '1ABCDE',
          result: 'unsure',
          duration_sec: 200
        } } }, token

        expect(last_response.status).to eq 200

        visit_json = json.data.attributes

        expect(visit_json.submitted_latitude).to eq 1
        expect(visit_json.submitted_longitude).to eq 2
        expect(visit_json.submitted_street_1).to eq 'A street'
        expect(visit_json.submitted_street_2).to eq 'Something special'
        expect(visit_json.submitted_city).to eq 'Testtown'
        expect(visit_json.submitted_state_code).to eq 'TT'
        expect(visit_json.submitted_zip_code).to eq '1ABCDE'
        expect(visit_json.result).to eq 'unsure'
        expect(visit_json.duration_sec).to eq 200
        expect(visit_json.total_points).not_to be_nil

        relationships_json = json.data.relationships

        expect(relationships_json.address).not_to be_nil
        expect(relationships_json.address.data.type).to eq 'addresses'
        expect(relationships_json.address.data.id).to eq '22'
        expect(relationships_json.user).not_to be_nil
        expect(relationships_json.user.data.type).to eq 'users'
        expect(relationships_json.user.data.id).to eq '11'
      end

      context 'when address already exists' do
        it 'creates a visit and updates the address' do
          address = create(:address, latitude: 1, longitude: 1)

          authenticated_post "visits", { data: { attributes: {
            submitted_latitude: 1,
            submitted_longitude: 1,
            submitted_street_1: 'A street',
            submitted_street_2: 'Something special',
            submitted_city: 'Testtown',
            submitted_state_code: 'TT',
            submitted_zip_code: '1ABCDE',
            result: 'interested',
            duration_sec: 200
          } } }, token

          expect(last_response.status).to eq 200

          new_visit = Visit.last
          expect(new_visit).not_to be_nil
          expect(new_visit.address).to eq address
          expect(new_visit.address.result).to eq 'interested'
        end
      end

      context 'when address doesn\'t already exist' do
        it 'creates a visit as well as an address' do
          authenticated_post "visits", { data: { attributes: {
            submitted_latitude: 1,
            submitted_longitude: 1,
            submitted_street_1: 'A street',
            submitted_street_2: 'Something special',
            submitted_city: 'Testtown',
            submitted_state_code: 'TT',
            submitted_zip_code: '1ABCDE',
            result: 'interested',
            duration_sec: 200
          } } }, token

          expect(last_response.status).to eq 200

          new_visit = Visit.last
          expect(new_visit).not_to be_nil

          new_address = Address.last
          expect(new_visit.address).to eq new_address
          expect(new_visit.address.result).to eq 'interested'
        end
      end
    end
  end
end
