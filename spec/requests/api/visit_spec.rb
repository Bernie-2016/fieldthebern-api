require "rails_helper"

describe "Visit API" do
  describe "POST /visits" do
    it "requires authentication" do
      post "#{host}/visits"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        @user = create(:user, id: 11, email: "test-user@mail.com", password: "password")
      end

      it "should return the created visit, with score included" do
        create(:address, id: 1)

        authenticated_post "visits", {
          data: {
            attributes: { duration_sec: 200 },
            relationships: { address: { data: { id: 1, type: "addresses" } } }
          },
          included: [ { id: 1, type: "addresses" } ]
        }, token

        expect(last_response.status).to eq 200

        visit_json = json.data.attributes

        expect(visit_json.duration_sec).to eq 200
        expect(visit_json.total_points).not_to be_nil

        included_json = json.included
        scores_json = included_json.select { |include| include.type == "scores" }
        expect(scores_json.length).to eq 1
        score_json = scores_json.first.attributes
        expect(score_json.points_for_updates).to eq 0
        expect(score_json.points_for_knock).to eq 5
      end

      it "should update the user's total score" do
        create(:address, id: 1)

        expect(@user.total_points).to eq 0

        authenticated_post "visits", {
          data: {
            attributes: { duration_sec: 200 },
            relationships: { address: { data: { id: 1, type: "addresses" } } }
          },
          included: [ { id: 1, type: "addresses" } ]
        }, token

        expect(@user.reload.total_points).to eq 5
      end

      context "when address already exists" do
        context "when person already exists" do
          it "creates a visit, updates the address and the person" do
            address = create(:address, id: 1)
            create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)

            authenticated_post "visits", {
              data: {
                attributes: { duration_sec: 200 },
                relationships: {
                  address: { data: { id: 1, type: "addresses" } },
                  person: { data: { id: 10, type: "people" } }
                }
              },
              included: [
                {
                  type: "addresses",
                  id: 1,
                  attributes: {
                    latitude: 2.0,
                    longitude: 3.0,
                    city: "New York",
                    state_code: "NY",
                    zip_code: "12345",
                    street_1: "Test street",
                    street_2: "Additional data"
                  }
                },
                {
                  type: "people",
                  id: 10,
                  attributes: {
                    first_name: "John",
                    last_name: "Doe",
                    canvas_response: "leaning_for",
                    party_affiliation: "Democrat"
                  }
                }
              ]
            }, token

            expect(last_response.status).to eq 200

            expect(Person.count).to eq 1
            expect(Address.count).to eq 1

            modified_address = Address.find(1)
            expect(modified_address.latitude).to eq 2.0
            expect(modified_address.longitude).to eq 3.0
            expect(modified_address.city).to eq "New York"
            expect(modified_address.state_code).to eq "NY"
            expect(modified_address.zip_code).to eq "12345"
            expect(modified_address.street_1).to eq "Test street"
            expect(modified_address.street_2).to eq "Additional data"

            modified_person = Person.find(10)
            expect(modified_person.first_name).to eq "John"
            expect(modified_person.last_name).to eq "Doe"
            expect(modified_person.leaning_for?).to be true
            expect(modified_person.democrat_affiliation?).to be true

            expect(modified_person.address).to eq modified_address
            expect(modified_address.most_supportive_resident).to eq modified_person
            expect(modified_address.best_canvas_response).to eq modified_person.canvas_response
          end
        end
        context "when person does not exist" do
          it "creates a visit, updates the address, creates the person" do

            address = create(:address, id: 1)

            authenticated_post "visits", {
              data: {
                attributes: { duration_sec: 200 },
                relationships: {
                  address: { data: { id: 1, type: "addresses" } },
                  person: { data: { id: 10, type: "people" } }
                }
              },
              included: [
                {
                  type: "addresses",
                  id: 1,
                  attributes: {
                    latitude: 2.0,
                    longitude: 3.0,
                    city: "New York",
                    state_code: "NY",
                    zip_code: "12345",
                    street_1: "Test street",
                    street_2: "Additional data"
                  }
                },
                {
                  type: "people",
                  attributes: {
                    first_name: "John",
                    last_name: "Doe",
                    canvas_response: "leaning_for",
                    party_affiliation: "Democrat"
                  }
                }
              ]
            }, token

            expect(last_response.status).to eq 200
            expect(json.data.relationships.people.length).to eq 1

            expect(Person.count).to eq 1
            expect(Address.count).to eq 1

            modified_address = Address.find(1)
            expect(modified_address.latitude).to eq 2.0
            expect(modified_address.longitude).to eq 3.0
            expect(modified_address.city).to eq "New York"
            expect(modified_address.state_code).to eq "NY"
            expect(modified_address.zip_code).to eq "12345"
            expect(modified_address.street_1).to eq "Test street"
            expect(modified_address.street_2).to eq "Additional data"

            new_person = Person.last
            expect(new_person.first_name).to eq "John"
            expect(new_person.last_name).to eq "Doe"
            expect(new_person.leaning_for?).to be true
            expect(new_person.democrat_affiliation?).to be true

            expect(new_person.address).to eq modified_address
            expect(modified_address.most_supportive_resident).to eq new_person
            expect(modified_address.best_canvas_response).to eq new_person.canvas_response
          end
        end

        context "when some people exist, some don't" do
          it "creates a visit, updates the address, creates people that don't exist, updates people that do" do
            address = create(:address, id: 1)
            create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)

            authenticated_post "visits", {
              data: {
                attributes: { duration_sec: 200 },
                relationships: {
                  address: { data: { id: 1, type: "addresses" } },
                  person: { data: { id: 10, type: "people" } }
                }
              },
              included: [
                {
                  type: "addresses",
                  id: 1,
                  attributes: {
                    latitude: 2.0,
                    longitude: 3.0,
                    city: "New York",
                    state_code: "NY",
                    zip_code: "12345",
                    street_1: "Test street",
                    street_2: "Additional data"
                  }
                },
                {
                  type: "people",
                  id: 10,
                  attributes: {
                    first_name: "John",
                    last_name: "Doe",
                    canvas_response: "leaning_for",
                    party_affiliation: "Democrat"
                  }
                },
                {
                  type: "people",
                  attributes: {
                    first_name: "Jane",
                    last_name: "Doe",
                    canvas_response: "strongly_for",
                    party_affiliation: "Republican"
                  }
                }
              ]
            }, token

            expect(last_response.status).to eq 200

            expect(Person.count).to eq 2
            expect(Address.count).to eq 1

            modified_address = Address.find(1)
            expect(modified_address.latitude).to eq 2.0
            expect(modified_address.longitude).to eq 3.0
            expect(modified_address.city).to eq "New York"
            expect(modified_address.state_code).to eq "NY"
            expect(modified_address.zip_code).to eq "12345"
            expect(modified_address.street_1).to eq "Test street"
            expect(modified_address.street_2).to eq "Additional data"

            modified_person = Person.find(10)
            expect(modified_person.first_name).to eq "John"
            expect(modified_person.last_name).to eq "Doe"
            expect(modified_person.leaning_for?).to be true
            expect(modified_person.democrat_affiliation?).to be true

            new_person = Person.find_by(first_name: "Jane")
            expect(new_person).to be_persisted
            expect(new_person.last_name).to eq "Doe"
            expect(new_person.strongly_for?).to be true
            expect(new_person.republican_affiliation?).to be true

            expect(modified_person.address).to eq modified_address
            expect(new_person.address).to eq modified_address
            expect(modified_address.most_supportive_resident).to eq new_person
            expect(modified_address.best_canvas_response).to eq new_person.canvas_response
          end
        end
      end

      context "when address doesn\'t already exist" do
        it "creates the visit, the address and the people", vcr: { cassette_name: "requests/api/visits/create_visit/creates_the_visit_the_addres_and_the_people" }  do
          authenticated_post "visits", {
            data: {
              attributes: { duration_sec: 200 }
            },
            included: [
              {
                type: "addresses",
                attributes: {
                  latitude: 40.771913,
                  longitude: -73.9673735,
                  street_1: "5th Avenue",
                  city: "New York",
                  state_code: "NY"
                }
              },
              {
                type: "people",
                attributes: {
                  first_name: "John",
                  last_name: "Doe",
                  canvas_response: "leaning_for",
                  party_affiliation: "Democrat"
                }
              }
            ]
          }, token

          expect(last_response.status).to eq 200

          expect(Person.count).to eq 1
          expect(Address.count).to eq 1


          new_address = Address.last
          # basic fields
          expect(new_address.latitude).to eq 40.771913
          expect(new_address.longitude).to eq -73.9673735
          expect(new_address.street_1)
          expect(new_address.city).to eq "New York"
          expect(new_address.street_1).to eq "5th Avenue"
          expect(new_address.state_code).to eq "NY"
          # USPS verified fields
          expect(new_address.usps_verified_street_1).to eq "5 AVENUE A"
          expect(new_address.usps_verified_street_2).to eq ""
          expect(new_address.usps_verified_city).to eq "NEW YORK"
          expect(new_address.usps_verified_state).to eq "NY"
          expect(new_address.usps_verified_zip).to eq "10009-7944"

          new_person = Person.last
          expect(new_person.first_name).to eq "John"
          expect(new_person.last_name).to eq "Doe"
          expect(new_person.leaning_for?).to be true
          expect(new_person.democrat_affiliation?).to be true

          expect(new_person.address).to eq new_address
          expect(new_address.most_supportive_resident).to eq new_person
          expect(new_address.best_canvas_response).to eq new_person.canvas_response
        end
      end
    end
  end
end
