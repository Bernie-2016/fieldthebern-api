require "rails_helper"
require "ground_game/scenario/match_address"

module GroundGame
  module Scenario
    describe MatchAddress do
      describe "#call" do
        context "when the address doesn't exist" do
          it "returns 404 if the address doesn't exist in the db", vcr: { cassette_name: "lib/ground_game/scenario/match_address/returns_404_if_the_address_doesnt_exist_in_the_db" } do
            address_params ={
              street_1: "5th Avenue",
              city: "New York",
              state_code: "NY"
            }

            matched, code, error, address = MatchAddress.new(address_params).call

            expect(matched).to be false
            expect(code).to eq 404
            expect(error).to eq "No match for this address"
            expect(address).to be_nil
          end

          it "returns 400 if not enough parameters provided for easypost", vcr: { cassette_name: "lib/ground_game/scenario/match_address/it_returns_400_if_not_enough_parameters_provided_for_easypost" } do
            address_params ={
              street_1: "5th avenue",
              city: "New York",
            }

            matched, code, error, address = MatchAddress.new(address_params).call

            expect(matched).to be false
            expect(code).to eq 400
            expect(error).to eq "Insufficient address data provided. A city and state or a zip must be provided."
            expect(address).to be_nil

            address_params ={
              city: "New York",
              state_code: "NY",
            }

            matched, code, error, address = MatchAddress.new(address_params).call

            expect(matched).to be false
            expect(code).to eq 400
            expect(error).to eq "Insufficient address data provided. A street must be provided."
            expect(address).to be_nil
          end

          it "returns 400 if address not found by easypost", vcr: { cassette_name: "lib/ground_game/scenario/match_address/it_returns_400_if_address_not_found_by_easypost" } do
            address_params ={
              street_1: "A non existant address to trigger proper error",
              city: "New York",
              state_code: "NY",
            }

            matched, code, error, address = MatchAddress.new(address_params).call

            expect(matched).to be false
            expect(code).to eq 400
            expect(error).to eq "Address Not Found."
            expect(address).to be_nil
          end

          it "returns an existing address with people included if the address exists", vcr: { cassette_name: "lib/ground_game/scenario/match_address/returns_an_existing_address_with_people_included_if_the_address_exists" } do
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
            person_a = create(:person, id: 5, address: address, canvas_response: :strongly_for)
            person_b = create(:person, id: 6, address: address, canvas_response: :leaning_for)

            address.people = [person_a, person_b]
            address.most_supportive_resident = person_a
            address.best_canvas_response = person_a.canvas_response
            address.save!

            address_params ={
              street_1: "5th Avenue",
              city: "New York",
              state_code: "NY"
            }

            matched, code, error, matches = MatchAddress.new(address_params).call

            expect(code).to eq 200

            expect(matches.length).to eq 1

            matched_address = matches.first
            expect(matched_address.latitude).to eq 1.0
            expect(matched_address.longitude).to eq 1.0
            expect(matched_address.street_1).to eq "5th Avenue"
            expect(matched_address.street_2).to eq ""
            expect(matched_address.city).to eq "New York"
            expect(matched_address.state_code).to eq "NY"
            expect(matched_address.zip_code).to eq ""
            expect(matched_address.best_canvas_response).to eq "strongly_for"

            expect(matched_address.most_supportive_resident_id).to eq 5
            expect(matched_address.people.map(&:id)).to contain_exactly 5, 6
          end
        end
      end
    end
  end
end
