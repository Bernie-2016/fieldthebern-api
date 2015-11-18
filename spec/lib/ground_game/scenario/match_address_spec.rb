require "rails_helper"
require "ground_game/scenario/match_address"

module GroundGame
  module Scenario
    describe MatchAddress do
      describe "#call" do
        context "when it succeeds" do
          it "returns an existing address with people included if the address exists", vcr: { cassette_name: "lib/ground_game/scenario/match_address/successful_easypost_request" } do
            address = create(:address,
              id: 1,
              latitude: 1,
              longitude: 1,
              street_1: "5th Avenue",
              street_2: "",
              city: "New York",
              zip_code: "",
              state_code: "NY",
              usps_verified_street_1: "5 AVENUE A",
              usps_verified_street_2: "",
              usps_verified_city: "NEW YORK",
              usps_verified_state: "NY",
              usps_verified_zip: "10009-7944")
            person_a = create(:person, id: 5, address: address, canvass_response: :strongly_for)
            person_b = create(:person, id: 6, address: address, canvass_response: :leaning_for)

            address.people = [person_a, person_b]
            address.most_supportive_resident = person_a
            address.best_canvass_response = person_a.canvass_response
            address.save!

            address_params ={
              street_1: "5th Avenue",
              city: "New York",
              state_code: "NY"
            }

            result = MatchAddress.new(address_params).call

            expect(result.success?).to be true
            expect(result.address.nil?).to be false

            matched_address = result.address
            expect(matched_address.latitude).to eq 1.0
            expect(matched_address.longitude).to eq 1.0
            expect(matched_address.street_1).to eq "5th Avenue"
            expect(matched_address.street_2).to eq ""
            expect(matched_address.city).to eq "New York"
            expect(matched_address.state_code).to eq "NY"
            expect(matched_address.zip_code).to eq ""
            expect(matched_address.best_is_strongly_for?).to be true

            expect(matched_address.most_supportive_resident_id).to eq 5
            expect(matched_address.people.map(&:id)).to contain_exactly 5, 6
          end
        end

        context "when it fails" do
          it "handles a GroundGame::AddressUnmatched", vcr: { cassette_name: "lib/ground_game/scenario/match_address/successful_easypost_request" } do
            address_params ={
              street_1: "5th Avenue",
              city: "New York",
              state_code: "NY"
            }

            result = MatchAddress.new(address_params).call

            expect(result.success?).to be false
            expect(result.error.status).to eq 404
            expect(result.error.detail).to eq "The requested address does not exist in the database."
            expect(result.address).to be_nil
          end

          it "handles an EasyPost::Error" do
            address_params ={
              street_1: "5th avenue",
              city: "New York",
            }

            VCR.use_cassette "lib/ground_game/scenario/match_address/failed_easypost_request_no_state" do
              result = MatchAddress.new(address_params).call

              expect(result.success?).to be false
              expect(result.error.status).to eq 400
              expect(result.error.detail).to eq "Insufficient address data provided. A city and state or a zip must be provided."
              expect(result.address).to be_nil
            end


            address_params ={
              city: "New York",
              state_code: "NY",
            }

            VCR.use_cassette "lib/ground_game/scenario/match_address/failed_easypost_request_no_street" do
              result = MatchAddress.new(address_params).call

              expect(result.success?).to be false
              expect(result.error.status).to eq 400
              expect(result.error.detail).to eq "Insufficient address data provided. A street must be provided."
              expect(result.address).to be_nil
            end
          end
        end
      end
    end
  end
end
