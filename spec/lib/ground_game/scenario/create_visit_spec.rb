require "rails_helper"
require "ground_game/scenario/create_visit"

module GroundGame
  module Scenario

    describe CreateVisit do

      describe "#call" do

        let(:user) { create(:user, email: "josh@cookacademy.com") }

        context "when it succeeds" do

          it "returns a visit" do
            address = create(:address, id: 1)
            create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)

            visit_params = { duration_sec: 150 }
            address_params = { id: 1 }
            people_params = [{ id: 10 }]

            result = CreateVisit.new(visit_params, address_params, people_params, user).call
            expect(result.success?).to be true
            expect(result.visit).not_to be_nil
            expect(result.error).to be_nil
          end

          it "computes and assigns the score" do
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

            visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit
            expect(visit.total_points).not_to be_nil
          end

          context "when the address already exists" do

            it "creates an address_update with proper contents" do
              address = create(:address, id: 1)
              visit_params = { duration_sec: 150 }

              address_params = { id: 1 }
              people_params = []

              visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit
              address_update = AddressUpdate.last
              expect(address_update.visit).to eq visit
              expect(address_update.address).to eq address
              expect(address_update.modified?).to be true
            end

            context "when the person already exists" do
              it "creates a person_update with proper contents for each person" do
                address = create(:address, id: 1)
                create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)
                create(:person, id: 11, address: address, canvas_response: :leaning_against, party_affiliation: :republican_affiliation)

                visit_params = { duration_sec: 150 }

                address_params = {
                  id: 1
                }

                people_params = [{
                  id: 10,
                  canvas_response: "Leaning for",
                  party_affiliation: "Democrat"
                }, {
                  id: 11,
                  canvas_response: "Strongly for",
                  party_affiliation: "Independent"
                }]

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                first_person_update = PersonUpdate.find_by(person_id: 10)
                expect(first_person_update).not_to be_nil
                expect(first_person_update.visit).to eq visit
                expect(first_person_update.modified?).to be true
                expect(first_person_update.old_canvas_response).to eq "unknown"
                expect(first_person_update.new_canvas_response).to eq "leaning_for"
                expect(first_person_update.old_party_affiliation).to eq "unknown_affiliation"
                expect(first_person_update.new_party_affiliation).to eq "democrat_affiliation"

                second_person_update = PersonUpdate.find_by(person_id: 11)
                expect(second_person_update).not_to be_nil
                expect(second_person_update.visit).to eq visit
                expect(second_person_update.modified?).to be true
                expect(second_person_update.old_canvas_response).to eq "leaning_against"
                expect(second_person_update.new_canvas_response).to eq "strongly_for"
                expect(second_person_update.old_party_affiliation).to eq "republican_affiliation"
                expect(second_person_update.new_party_affiliation).to eq "independent_affiliation"
              end

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

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                expect(visit.duration_sec).to eq 150
                expect(visit.address.id).to eq 1
                expect(visit.people.length).to eq 1
                expect(visit.people.first.id).to eq 10
              end
            end

            context "when the person does not exist" do

              it "creates a person_update with proper contents for each person" do
                address = create(:address, id: 1)
                visit_params = { duration_sec: 150 }

                address_params = {
                  id: 1
                }

                people_params = [{
                  first_name: "John",
                  last_name: "Doe",
                  canvas_response: "Leaning for",
                  party_affiliation: "Democrat"
                }, {
                  first_name: "Jane",
                  last_name: "Doe",
                  canvas_response: "Strongly for",
                  party_affiliation: "Independent"
                }]

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                first_person = Person.find_by(first_name: "John")
                first_person_update = PersonUpdate.find_by(person: first_person)
                expect(first_person_update).not_to be_nil
                expect(first_person_update.visit).to eq visit
                expect(first_person_update.created?).to be true
                expect(first_person_update.old_canvas_response).to eq "unknown"
                expect(first_person_update.new_canvas_response).to eq "leaning_for"
                expect(first_person_update.old_party_affiliation).to eq "unknown_affiliation"
                expect(first_person_update.new_party_affiliation).to eq "democrat_affiliation"

                second_person = Person.find_by(first_name: "Jane")
                second_person_update = PersonUpdate.find_by(person: second_person)
                expect(second_person_update).not_to be_nil
                expect(second_person_update.visit).to eq visit
                expect(second_person_update.created?).to be true
                expect(second_person_update.old_canvas_response).to eq "unknown"
                expect(second_person_update.new_canvas_response).to eq "strongly_for"
                expect(second_person_update.old_party_affiliation).to eq "unknown_affiliation"
                expect(second_person_update.new_party_affiliation).to eq "independent_affiliation"
              end

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

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                expect(visit.duration_sec).to eq 150
                expect(visit.address.id).to eq 1
                expect(visit.people.length).to eq 1
                expect(visit.people.first.first_name).to eq "John"
              end
            end
          end

          context "when the address doesn't exist"do
            it "creates an address_update with proper contents", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/creates_an_address_update_with_proper_contents" } do
              visit_params = { duration_sec: 150 }

              address_params = {
                latitude: 40.771913,
                longitude: -73.9673735,
                street_1: "5th Avenue",
                city: "New York",
                state_code: "NY"
              }

              people_params = []

              visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

              address_update = AddressUpdate.last
              expect(address_update.visit).to eq visit
              expect(address_update.address).to eq visit.address
              expect(address_update.created?).to be true
            end

            it "creates the visit, the address and the people", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/creates_the_visit_the_addres_and_the_people" } do
              visit_params = { duration_sec: 150 }

              address_params = {
                latitude: 40.771913,
                longitude: -73.9673735,
                street_1: "5th Avenue",
                city: "New York",
                state_code: "NY"
              }

              people_params = [{
                first_name: "John",
                last_name: "Doe",
                canvas_response: "Leaning for",
                party_affiliation: "Democrat"
              }]

              visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

              expect(visit.duration_sec).to eq 150

              address = visit.address
              expect(address.latitude).to eq 40.771913
              expect(address.longitude).to eq -73.9673735
              expect(address.street_1)
              expect(address.city).to eq "New York"
              expect(address.street_1).to eq "5th Avenue"
              expect(address.state_code).to eq "NY"

              expect(address.usps_verified_street_1).to eq "5 AVENUE A"
              expect(address.usps_verified_street_2).to eq ""
              expect(address.usps_verified_city).to eq "NEW YORK"
              expect(address.usps_verified_state).to eq "NY"
              expect(address.usps_verified_zip).to eq "10009-7944"

              expect(visit.people.length).to eq 1
              expect(visit.people.first.first_name).to eq "John"
            end
          end

        end

        context "when it fails" do

          it "returns an error object" do
            create(:address, id: 1, latitude: 1, longitude: 2)
            visit_params = { duration_sec: 150 }

            address_params = { id: 1, latitude: 1, longitude: 3, best_canvas_response: "invalid_value" }
            people_params = []

            result = CreateVisit.new(visit_params, address_params, people_params, user).call
            expect(result.success?).to be false
            expect(result.visit).to be_nil
            expect(result.error).not_to be_nil
          end

          describe "error handling" do
            before do
              create(:address, id: 10, latitude: 40.771913, longitude: -73.9673735, street_1: "5th Avenue", city: "New York", state_code: "NY")
            end

            it "handles ArgumentError with code 422" do
              visit_params = { duration_sec: 150 }
              address_params = { id: 10}
              people_params = [{ first_name: "John", last_name: "Doe", canvas_response: "invalid response" }]

              error = CreateVisit.new(visit_params, address_params, people_params, user).call.error

              expect(error.id).to eq "ARGUMENT_ERROR"
              expect(error.title).to eq "Argument error"
              expect(error.detail).to eq "'invalid response' is not a valid canvas_response"
              expect(error.status).to eq 422
            end

            it "handles ActiveRecord::RecordNotFound with code 404" do
              visit_params = { duration_sec: 150 }
              address_params = { id: 11}
              people_params = [{ first_name: "John", last_name: "Doe" }]

              error = CreateVisit.new(visit_params, address_params, people_params, user).call.error

              expect(error.id).to eq "RECORD_NOT_FOUND"
              expect(error.title).to eq "Record not found"
              expect(error.detail).to eq "Couldn't find Address with 'id'=11"
              expect(error.status).to eq 404
            end
          end

          describe "cleanup" do

            it "cleans up everything when address update fails" do
              create(:address, id: 1, latitude: 1, longitude: 2)
              visit_params = { duration_sec: 150 }

              address_params = { id: 1, latitude: 1, longitude: 3, best_canvas_response: "invalid_value" }
              people_params = []

              result = CreateVisit.new(visit_params, address_params, people_params, user).call
              expect(result.success?).to be false

              expect(Visit.count).to eq 0
              expect(Address.count).to eq 1
              expect(Address.first.longitude).to eq 2
              expect(Person.count).to eq 0
              expect(Score.count).to eq 0
            end

            it "cleans up everything when address creation fails", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/cleans_up_everything_when_address_update_fails" } do
              visit_params = { duration_sec: 150 }
              address_params = { best_canvas_response: "invalid_value" }
              people_params = []

              result = CreateVisit.new(visit_params, address_params, people_params, user).call
              expect(result.success?).to be false

              expect(Visit.count).to eq 0
              expect(Address.count).to eq 0
              expect(Person.count).to eq 0
              expect(Score.count).to eq 0
            end

            it "cleans up everything when person update fails" do
              address = create(:address, id: 1, latitude: 1, longitude: 2)
              create(:person, id: 2, first_name: "John", last_name: "Doe", address: address)

              visit_params = { duration_sec: 150 }
              address_params = { id: 1, latitude: 1, longitude: 3 }
              people_params = [{ id: 2, first_name: "Jake", last_name: "Doe", canvas_response: "invalid_value" }]

              result = CreateVisit.new(visit_params, address_params, people_params, user).call
              expect(result.success?).to be false

              expect(Visit.count).to eq 0

              expect(Address.count).to eq 1

              address = Address.last
              expect(address.longitude).to eq 2

              expect(Person.count).to eq 1
              expect(Person.last.first_name).to eq "John"

              expect(Score.count).to eq 0
            end

            it "cleans up everything when person creation fails" do
              address = create(:address, id: 1, latitude: 1, longitude: 2)
              create(:person, id: 2, first_name: "John", last_name: "Doe", address: address)

              visit_params = { duration_sec: 150 }
              address_params = { id: 1, latitude: 1, longitude: 3 }
              people_params = [
                { id: 2, first_name: "Jake", last_name: "Doe" },
                { first_name: "John", last_name: "Smith", canvas_response: "invalid_value" }
              ]

              result = CreateVisit.new(visit_params, address_params, people_params, user).call
              expect(result.success?).to be false

              expect(Visit.count).to eq 0

              expect(Address.count).to eq 1

              address = Address.last
              expect(address.longitude).to eq 2

              expect(Person.count).to eq 1
              expect(Person.last.first_name).to eq "John"

              expect(Score.count).to eq 0
            end
          end
        end
      end
    end
  end
end
