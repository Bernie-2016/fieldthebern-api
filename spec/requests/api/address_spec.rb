require "rails_helper"

describe "Address API" do
  describe "GET /addresses" do

    it "requires authentication" do
      get "#{host}/addresses"
      expect(last_response.status).to eq 401
      expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
    end

    context "when authenticated" do

      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      context "when searching by radius" do
        it "returns a list of addresses within the specified radius of the specified point" do
          create(:address, latitude: 1, longitude: 1)
          create(:address, latitude: -1, longitude: -1)
          create(:address, latitude: -1, longitude: 1)
          create(:address, latitude: 1, longitude: -1)
          create(:address, latitude: 20, longitude: 20)

          authenticated_get "addresses", {
            latitude: 0,
            longitude: 0,
            radius: 200 * 1000
          }, token

          expect(last_response.status).to eq 200
          expect(json.data.length).to eq 4
        end

        it "includes 'last_visited_by' for addresses that have it" do
          latest_visitor = create(:user, first_name: "Visitor")
          create(:address, latitude: 1, longitude: 1, last_visited_by: latest_visitor)
          create(:address, latitude: -1, longitude: -1)

          authenticated_get "addresses", {
            latitude: 0,
            longitude: 0,
            radius: 200 * 1000
          }, token

          expect(json.included.length).to eq 1
          expect(json.included.first.attributes.first_name).to eq "Visitor"
        end
      end

      context "when searching by parameters instead of radius" do
        it "should return an error response when it fails", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" }  do
          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "ADDRESS_UNMATCHED"
        end

        it "returns an existing address the address exists", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" } do
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
          person = create(:person, id: 5, address: address, canvass_response: :strongly_for)

          address.most_supportive_resident = person
          address.best_canvass_response = person.canvass_response
          address.save!

          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token

          expect(last_response.status).to eq 200
          expect(json.data.length).to eq 1

          address_json = json.data[0]
          address_attributes = address_json.attributes

          expect(address_attributes.latitude).to eq 1.0
          expect(address_attributes.longitude).to eq 1.0
          expect(address_attributes.street_1).to eq "5th Avenue"
          expect(address_attributes.street_2).to eq ""
          expect(address_attributes.city).to eq "New York"
          expect(address_attributes.state_code).to eq "NY"
          expect(address_attributes.zip_code).to eq ""
          expect(address_attributes.best_canvass_response).to eq "strongly_for"
          expect(address_attributes.last_canvass_response).not_to be_nil

          address_relationships = address_json.relationships
          expect(address_relationships.most_supportive_resident.data.id).to eq "5"
        end

        it "includes people with the response", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" } do
          address = create(:address,
            street_1: "5th Avenue",
            street_2: "",
            city: "New York",
            zip_code: "",
            state_code: "NY")
          person_a = create(:person, id: 5, address: address, canvass_response: :strongly_for)
          person_b = create(:person, id: 6, address: address, canvass_response: :leaning_for)

          address.people = [person_a, person_b]
          address.save!

          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token

          address_relationships = json.data[0].relationships
          expect(address_relationships.people.data.map(&:id)).to contain_exactly "5","6"

          expect(json.included.length).to eq 2
          expect(json.included.all? { |person| person.data.type == "people" }).to be true
        end

        it "includes the latest visitor with the response", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" } do
          visitor = create(:user, first_name: "Visitor")
          address = create(:address,
            street_1: "5th Avenue",
            street_2: "",
            city: "New York",
            zip_code: "",
            state_code: "NY",
            last_visited_by: visitor)

          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token

          expect(last_response.status).to eq 200

          address_relationships = json.data[0].relationships
          expect(address_relationships.last_visited_by.data.id).to eq visitor.id.to_s

          expect(json.included.length).to eq 1
          expect(json.included.first.data.type).to eq "users"
          expect(json.included.first.data.attributes.first_name).to eq "Visitor"
        end
      end
    end
  end
end
