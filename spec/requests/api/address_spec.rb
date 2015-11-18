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
        it "should return an error response when it failes", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" }  do
          authenticated_get "addresses", {
            street_1: "5th Avenue",
            city: "New York",
            state_code: "NY"
          }, token

          expect(last_response.status).to eq 404
          expect(json.errors.length).to eq 1
          error = json.errors.first
          expect(error.id).to eq "ADDRESS_UNMATCHED"
          expect(error.title).to eq "Address unmatched"
          expect(error.detail).to eq "The requested address does not exist in the database."
          expect(error.status).to eq 404
        end

        it "returns an existing address with people included if the address exists", vcr: { cassette_name: "requests/api/addresses/succesful_easypost_response" } do
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
          expect(address_relationships.people.data.map(&:id)).to contain_exactly "5","6"
          expect(json.included.length).to eq 2
          expect(json.included.all? { |person| person.type == "people" }).to be true
          expect(json.included.all? { |person| person.relationships.address.data.id == "1" }).to be true
        end
      end

    end
  end
end
