require "rails_helper"
require "ground_game/scenario/create_visit"

module GroundGame
  module Scenario

    describe CreateVisit do

      describe "#call" do

        let(:user) { create(:user, email: "josh@cookacademy.com") }

        it "computes and assigns the score"

        context "when the address already exists" do
          context "when the person already exists" do
            it "creates a visit, updates the address, updates the person" do
              address = create(:address, id: 1)
              create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)

              visit_params = { duration_sec: 150 }

              address_params = {
                id: 1,
                latitude: 2.0,
                longitude: 3.0,
                city: "New York",
                state_code: "NY",
                zip_code: "12345",
                street_1: "Test street",
                street_2: "Additional data"
              }

              people_params = [{
                id: 10,
                first_name: "John",
                last_name: "Doe",
                canvas_response: "Leaning for",
                party_affiliation: "Democrat"
              }]

              visit = CreateVisit.new(visit_params, address_params, people_params, user).call

              expect(visit.duration_sec).to eq 150
              expect(visit.address.id).to eq 1
              expect(visit.people.length).to eq 1
              expect(visit.people.first.id).to eq 10
            end
          end

          context "when the person does not exist" do
            it "creates a visit, updates the address and creates the person" do
              create(:address, id: 1)

              visit_params = { duration_sec: 150 }

              address_params = {
                id: 1,
                latitude: 2.0,
                longitude: 3.0,
                city: "New York",
                state_code: "NY",
                zip_code: "12345",
                street_1: "Test street",
                street_2: "Additional data"
              }

              people_params = [{
                first_name: "John",
                last_name: "Doe",
                canvas_response: "Leaning for",
                party_affiliation: "Democrat"
              }]

              visit = CreateVisit.new(visit_params, address_params, people_params, user).call

              expect(visit.duration_sec).to eq 150
              expect(visit.address.id).to eq 1
              expect(visit.people.length).to eq 1
              expect(visit.people.first.first_name).to eq "John"
            end
          end
        end

        context "when the address doesn\'t exist" do
          it "creates the visit, the address and the people" do
            visit_params = { duration_sec: 150 }

            address_params = {
              latitude: 2.0,
              longitude: 3.0,
              city: "New York",
              state_code: "NY",
              zip_code: "12345",
              street_1: "Test street",
              street_2: "Additional data"
            }

            people_params = [{
              first_name: "John",
              last_name: "Doe",
              canvas_response: "Leaning for",
              party_affiliation: "Democrat"
            }]

            visit = CreateVisit.new(visit_params, address_params, people_params, user).call

            expect(visit.duration_sec).to eq 150
            expect(visit.address.city).to eq "New York"
            expect(visit.people.length).to eq 1
            expect(visit.people.first.first_name).to eq "John"
          end
        end
      end
    end
  end
end
