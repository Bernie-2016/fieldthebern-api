require "rails_helper"

describe "Address API" do
  describe "GET /address" do
    it "requires authentication" do
      get "#{host}/addresses"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do

      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

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

      context "when searching by parameters instead of scope" do
        it "returns 404 if the address doesn't exist in the db", vcr: { cassette_name: "requests/api/addresses/returns_404_if_the_address_doesnt_exist_in_the_db" } do
          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token
          expect(last_response.status).to eq 404
          expect(json.error).to eq "No match for this address"
        end

        it "returns 400 if not enough parameters provided for easypost", vcr: { cassette_name: "requests/api/addresses/it_returns_400_if_not_enough_parameters_provided_for_easypost" } do
          authenticated_get "addresses", {
            street_1: "5th avenue",
            city: "New York",
          }, token
          expect(json.error).to eq "Insufficient address data provided. A city and state or a zip must be provided."
          expect(last_response.status).to eq 400

          authenticated_get "addresses", {
            city: "New York",
            state_code: "NY",
          }, token
          expect(json.error).to eq "Insufficient address data provided. A street must be provided."
          expect(last_response.status).to eq 400
        end

        it "returns 400 if address not found by easypost", vcr: { cassette_name: "requests/api/addresses/it_returns_400_if_address_not_found_by_easypost" } do
          authenticated_get "addresses", {
            street_1: "A non existant address to trigger proper error",
            city: "New York",
            state_code: "NY",
          }, token
          expect(json.error).to eq "Address Not Found."
          expect(last_response.status).to eq 400
        end

        it "returns an existing address with people included if the address exists", vcr: { cassette_name: "requests/api/addresses/returns_an_existing_address_with_people_included_if_the_address_exists" } do
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
          expect(address_attributes.best_canvas_response).to eq "strongly_for"

          address_relationships = address_json.relationships
          expect(address_relationships.most_supportive_resident.data.id).to eq "5"
          expect(address_relationships.people.data.map(&:id)).to contain_exactly "5","6"

          expect(json.included.length).to eq 2
          expect(json.included.all? { |person| person.type == "people" }).to be true
          expect(json.included.all? { |person| person.relationships.address.data.id == "1" }).to be true
        end
      end

    end
  end
end
