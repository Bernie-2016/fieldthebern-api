require 'rails_helper'
require 'ground_game/scenario/create_visit'

module GroundGame
  module Scenario

    describe CreateVisit do

      describe "#call" do

        context 'when the address already exists' do
          it 'creates a visit and updates the address' do
            params = { submitted_latitude: 1, submitted_longitude: 1, result: :unsure, duration_sec: 150 }
            user = create(:user)
            address = create(:address, latitude: 1, longitude: 1)

            new_visit = CreateVisit.new(params, user).call

            expect(new_visit).to be_valid
            expect(new_visit.address).to eq address
            expect(new_visit.user).to eq user

            expect(new_visit.address.result).to eq new_visit.result
          end
        end

        context 'when the address doesn\'t exist' do
          it 'creates both the visit and the address' do
            params = { submitted_latitude: 1, submitted_longitude: 1, result: :unsure, duration_sec: 150 }
            user = create(:user)
            new_visit = CreateVisit.new(params, user).call

            expect(new_visit).to be_valid
            expect(Address.count).to eq 1
            expect(new_visit.address).to eq Address.last
            expect(new_visit.user).to eq user
            expect(new_visit.address.result).to eq new_visit.result
          end
        end
      end
    end
  end
end
