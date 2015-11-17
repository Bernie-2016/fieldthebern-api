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
            create(:person, id: 10, address: address, canvass_response: :unknown, party_affiliation: :unknown_affiliation)

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
            create(:person, id: 10, address: address, canvass_response: :unknown, party_affiliation: :unknown_affiliation)

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
              canvass_response: "Leaning for",
              party_affiliation: "Democrat"
            }]

            visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit
            expect(visit.total_points).not_to be_nil
          end

          it "updates the user's state code to the address state code" do
            user = create(:user, email: "josh@cookacademy.com", state_code: "MD")

            address = create(:address, id: 1, state_code: "CA")
            create(:person, id: 10, address: address, canvass_response: :unknown, party_affiliation: :unknown_affiliation)

            visit_params = { duration_sec: 150 }
            address_params = { id: 1 }
            people_params = [{ id: 10 }]

            result = CreateVisit.new(visit_params, address_params, people_params, user).call
            expect(result.success?).to be true
            user.reload
            expect(user.state_code).to eq "CA"
          end

          context "when the address already exists" do

            it "updates address.visited_at" do
              address = create(:address, id: 1)
              visit_params = {}
              address_params = { id: 1 }
              people_params = []
              result = CreateVisit.new(visit_params, address_params, people_params, user).call
              expect(result.success?).to eq true
              expect(address.reload.visited_at).to be_within(1.second).of(DateTime.now)
            end

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
                create(:person, id: 10, address: address, canvass_response: :unknown, party_affiliation: :unknown_affiliation)
                create(:person, id: 11, address: address, canvass_response: :leaning_against, party_affiliation: :republican_affiliation)

                visit_params = { duration_sec: 150 }

                address_params = {
                  id: 1
                }

                people_params = [{
                  id: 10,
                  canvass_response: "Leaning for",
                  party_affiliation: "Democrat"
                }, {
                  id: 11,
                  canvass_response: "Strongly for",
                  party_affiliation: "Independent"
                }]

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                first_person_update = PersonUpdate.find_by(person_id: 10)
                expect(first_person_update).not_to be_nil
                expect(first_person_update.visit).to eq visit
                expect(first_person_update.modified?).to be true
                expect(first_person_update.old_canvass_response).to eq "unknown"
                expect(first_person_update.new_canvass_response).to eq "leaning_for"
                expect(first_person_update.old_party_affiliation).to eq "unknown_affiliation"
                expect(first_person_update.new_party_affiliation).to eq "democrat_affiliation"

                second_person_update = PersonUpdate.find_by(person_id: 11)
                expect(second_person_update).not_to be_nil
                expect(second_person_update.visit).to eq visit
                expect(second_person_update.modified?).to be true
                expect(second_person_update.old_canvass_response).to eq "leaning_against"
                expect(second_person_update.new_canvass_response).to eq "strongly_for"
                expect(second_person_update.old_party_affiliation).to eq "republican_affiliation"
                expect(second_person_update.new_party_affiliation).to eq "independent_affiliation"
              end

              it "creates a visit, updates the address, updates the person" do
                address = create(:address, id: 1)
                create(:person, id: 10, address: address, canvass_response: :unknown, party_affiliation: :unknown_affiliation)

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
                  canvass_response: "Leaning for",
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
                  canvass_response: "Leaning for",
                  party_affiliation: "Democrat"
                }, {
                  first_name: "Jane",
                  last_name: "Doe",
                  canvass_response: "Strongly for",
                  party_affiliation: "Independent"
                }]

                visit = CreateVisit.new(visit_params, address_params, people_params, user).call.visit

                first_person = Person.find_by(first_name: "John")
                first_person_update = PersonUpdate.find_by(person: first_person)
                expect(first_person_update).not_to be_nil
                expect(first_person_update.visit).to eq visit
                expect(first_person_update.created?).to be true
                expect(first_person_update.old_canvass_response).to eq "unknown"
                expect(first_person_update.new_canvass_response).to eq "leaning_for"
                expect(first_person_update.old_party_affiliation).to eq "unknown_affiliation"
                expect(first_person_update.new_party_affiliation).to eq "democrat_affiliation"

                second_person = Person.find_by(first_name: "Jane")
                second_person_update = PersonUpdate.find_by(person: second_person)
                expect(second_person_update).not_to be_nil
                expect(second_person_update.visit).to eq visit
                expect(second_person_update.created?).to be true
                expect(second_person_update.old_canvass_response).to eq "unknown"
                expect(second_person_update.new_canvass_response).to eq "strongly_for"
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
                  canvass_response: "Leaning for",
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
            before do
              @visit_params = { duration_sec: 150 }
              @address_params = {
                latitude: 40.771913,
                longitude: -73.9673735,
                street_1: "5th Avenue",
                city: "New York",
                state_code: "NY"
              }
            end

            it "sets new_address.visited_at", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/successful_easypost_request" } do
              people_params = []
              result = CreateVisit.new(@visit_params, @address_params, people_params, user).call
              expect(result.success?).to eq true
              expect(Address.last.visited_at).to be_within(1.second).of(DateTime.now)
            end

            it "creates an address_update and address with proper contents", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/successful_easypost_request" } do


              people_params = []

              visit = CreateVisit.new(@visit_params, @address_params, people_params, user).call.visit

              address_update = AddressUpdate.last
              expect(address_update.visit).to eq visit
              expect(address_update.address).to eq visit.address
              expect(address_update.created?).to be true
              expect(address_update.address.not_home?).to be true
            end

            it "creates the visit, the address and the people", vcr: { cassette_name: "lib/ground_game/scenario/create_visit/successful_easypost_request" } do

              people_params = [{
                first_name: "John",
                last_name: "Doe",
                canvass_response: "Leaning for",
                party_affiliation: "Democrat"
              }]

              visit = CreateVisit.new(@visit_params, @address_params, people_params, user).call.visit

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

            address_params = { id: 1, latitude: 1, longitude: 3, best_canvass_response: "invalid_value" }
            people_params = []

            result = CreateVisit.new(visit_params, address_params, people_params, user).call
            expect(result.success?).to be false
            expect(result.visit).to be_nil
            expect(result.error).not_to be_nil
          end

          describe "error handling" do
            before do
              @address = create(:address, id: 10, latitude: 40.771913, longitude: -73.9673735, street_1: "5th Avenue", city: "New York", state_code: "NY")
            end

            it "handles ArgumentError with code 422" do
              visit_params = { duration_sec: 150 }
              address_params = { id: 10}
              people_params = [{ first_name: "John", last_name: "Doe", canvass_response: "invalid response" }]

              error = CreateVisit.new(visit_params, address_params, people_params, user).call.error

              expect(error.id).to eq "ARGUMENT_ERROR"
              expect(error.title).to eq "Argument error"
              expect(error.detail).to eq "'invalid response' is not a valid canvass_response"
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

            it "handles GroundGame::VisitNotAllowedError with code 403" do
              create(:address, id: 11, recently_visited?: true)

              visit_params = {}
              address_params = { id: 11}
              people_params = []

              error = CreateVisit.new(visit_params, address_params, people_params, user).call.error

              expect(error.id).to eq "VISIT_NOT_ALLOWED"
              expect(error.title).to eq "Visit not allowed"
              expect(error.detail).to eq "You can't submit the same address so quickly after it was last visited."
              expect(error.status).to eq 403
            end

            it "handles GroundGame::InvalidBestCanvassResponse with code 422" do
              visit_params = { duration_sec: 150 }
              address_params = { id: 10, best_canvass_response: "strongly_for"}
              people_params = []

              error = CreateVisit.new(visit_params, address_params, people_params, user).call.error

              expect(error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
              expect(error.title).to eq "Invalid best canvass response"
              expect(error.detail).to eq "Invalid argument 'strongly_for' for address.best_canvass_response"
              expect(error.status).to eq 422
            end
          end

          describe "cleanup" do

            it "cleans up everything when address update fails" do
              create(:address, id: 1, latitude: 1, longitude: 2)
              visit_params = { duration_sec: 150 }

              address_params = { id: 1, latitude: 1, longitude: 3, best_canvass_response: "invalid_value" }
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
              address_params = { best_canvass_response: "invalid_value" }
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
              people_params = [{ id: 2, first_name: "Jake", last_name: "Doe", canvass_response: "invalid_value" }]

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
                { first_name: "John", last_name: "Smith", canvass_response: "invalid_value" }
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

        context "when visiting the same address again" do
          it "passes if enough time has passed" do
            create(:address, id: 10, recently_visited?: false)
            visit_params = {}
            address_params = { id: 10 }
            people_params = []
            result = CreateVisit.new(visit_params, address_params, people_params, user).call

            expect(result.success?).to be true
          end
          it "fails if not enough time has passed" do
            create(:address, id: 10, recently_visited?: true)

            visit_params = {}
            address_params = { id: 10 }
            people_params = []
            result = CreateVisit.new(visit_params, address_params, people_params, user).call

            expect(result.success?).to be false
          end
        end

        describe "setting 'address.best_canvass_response' directly" do
          before do
            @address = create(:address, id: 1)
          end

          def create_visit_with_address_best_canvass_response_set_to(best_canvass_response)
            visit_params = { duration_sec: 200 }
            address_params = { id: 1, best_canvass_response: best_canvass_response }
            people_params = []

            CreateVisit.new(visit_params, address_params, people_params, user).call
          end

          it "should be allowed for 'asked_to_leave'" do
            result = create_visit_with_address_best_canvass_response_set_to "asked_to_leave"
            expect(@address.reload.asked_to_leave?).to be true
          end

          it "should be allowed for 'not_home'" do
            create_visit_with_address_best_canvass_response_set_to "not_home"
            expect(@address.reload.not_home?).to be true
          end

          it "should be allowed for 'not_yet_visited" do
            create_visit_with_address_best_canvass_response_set_to "not_yet_visited"
            expect(@address.reload.not_yet_visited?).to be true
          end

          it "should not be allowed for 'unknown'" do
            create_visit_with_address_best_canvass_response_set_to "unknown"
            expect(@address.reload.unknown?).to be false
          end

          it "should not be allowed for 'strongly_for'" do
            result = create_visit_with_address_best_canvass_response_set_to "strongly_for"
            expect(@address.reload.strongly_for?).to be false
            expect(result.error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
          end

          it "should not be allowed for 'leaning_for'" do
            result = create_visit_with_address_best_canvass_response_set_to "leaning_for"
            expect(@address.reload.leaning_for?).to be false
            expect(result.error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
          end

          it "should not be allowed for 'undecided'" do
            result = create_visit_with_address_best_canvass_response_set_to "undecided"
            expect(@address.reload.undecided?).to be false
            expect(result.error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
          end

          it "should not be allowed for 'leaning_against'" do
            result = create_visit_with_address_best_canvass_response_set_to "leaning_against"
            expect(@address.reload.leaning_against?).to be false
            expect(result.error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
          end

          it "should not be allowed for 'strongly_against'" do
            result = create_visit_with_address_best_canvass_response_set_to "strongly_against"
            expect(@address.reload.strongly_against?).to be false
            expect(result.error.id).to eq "INVALID_BEST_CANVASS_RESPONSE"
          end
        end

        describe "setting 'address.last_canvass_response'" do
          before do
            @address = create(:address, id: 1)
            @visit_params = {}
          end

          it "sets it to 'best_canvass_response' if there are no 'people_params' or 'last_canvass_response' parameter" do
            address_params = { id: 1, best_canvass_response: "not_home" }
            people_params = []

            CreateVisit.new(@visit_params, address_params, people_params, user).call

            expect(@address.reload.last_canvass_response).to eq "not_home"
          end

          it "sets it to 'last_canvass_response' if there are no 'people_params'" do
            address_params = { id: 1, best_canvass_response: "not_home", last_canvass_response: "asked_to_leave" }
            people_params = []

            CreateVisit.new(@visit_params, address_params, people_params, user).call

            expect(@address.reload.last_canvass_response).to eq "asked_to_leave"
          end

          it "sets it to 'most_supportive_resident.canvas_response' if there are 'people_params'" do
            address_params = { id: 1 }
            people_params = [
              { canvass_response: "leaning_for" },
              { canvass_response: "strongly_for" },
              { canvass_response: "leaning_against"}
            ]

            CreateVisit.new(@visit_params, address_params, people_params, user).call

            expect(@address.reload.last_canvass_response).to eq "strongly_for"
          end
        end
      end
    end
  end
end
