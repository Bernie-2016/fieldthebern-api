require 'rails_helper'
require 'ground_game/scenario/create_visit'

module GroundGame
  module Scenario

    describe CreateVisit do

      describe "#call" do

        it 'computes and assigns the score', vcr: { cassette_name: 'requests/lib/ground_game/scenario/create_visit/computes_and_assigns_the_score' } do
          params = { submitted_latitude: 40.780898, submitted_longitude: -73.247246, result: :unsure, duration_sec: 150 }
          user = create(:user)

          new_visit = CreateVisit.new(params, user).call
          expect(new_visit.total_points).not_to be_nil
        end

        context 'when the address already exists' do
          it 'creates a visit and updates the address', vcr: { cassette_name: 'requests/lib/ground_game/scenario/create_visit/creates_a_visit_and_updates_the_address' } do
            params = { submitted_latitude: 40.780898, submitted_longitude: -73.247246, result: :unsure, duration_sec: 150 }
            user = create(:user)
            address = create(:address, latitude: 40.7809482, longitude: -73.2472665)

            new_visit = CreateVisit.new(params, user).call

            expect(new_visit).to be_valid

            expect(new_visit.address).to eq address
            expect(new_visit.user).to eq user

            expect(new_visit.address.latest_result).to eq new_visit.result
          end

          it 'inferrs address from street_1 if coordinates do not match', vcr: { cassette_name: 'requests/lib/ground_game/scenario/create_visit/inferrs_address_from_street_1_if_coordinates_do_not_match' }  do
            params = { submitted_latitude: 40.780898, submitted_longitude: -73.247246, submitted_street_1: 'A street', result: :unsure, duration_sec: 150 }
            user = create(:user)
            address = create(:address, latitude: 40.780898, longitude: -73.247247, street_1: 'A street')

            new_visit = CreateVisit.new(params, user).call

            expect(new_visit).to be_valid

            expect(new_visit.address).to eq address
            expect(new_visit.user).to eq user

            expect(new_visit.address.latest_result).to eq new_visit.result
          end
        end

        context 'when the address doesn\'t exist' do
          it 'creates both the visit and the address', vcr: { cassette_name: 'requests/lib/ground_game/scenario/create_visit/creates_both_the_visit_and_the_address' }  do
            params = { submitted_latitude: 40.780898, submitted_longitude: -73.247246, result: :unsure, duration_sec: 150 }
            user = create(:user)
            new_visit = CreateVisit.new(params, user).call

            expect(new_visit).to be_valid
            expect(Address.count).to eq 1
            expect(new_visit.address).to eq Address.last
            expect(new_visit.user).to eq user
            expect(new_visit.address.latest_result).to eq new_visit.result
            expect(new_visit.address.street_1).to eq new_visit.submitted_street_1
            expect(new_visit.address.street_2).to eq new_visit.submitted_street_2
            expect(new_visit.address.city).to eq new_visit.submitted_city
            expect(new_visit.address.state_code).to eq new_visit.submitted_state_code
            expect(new_visit.address.zip_code).to eq new_visit.submitted_zip_code
            expect(new_visit.address.latitude).to eq new_visit.corrected_latitude
            expect(new_visit.address.longitude).to eq new_visit.corrected_longitude
          end
        end
      end
    end
  end
end
