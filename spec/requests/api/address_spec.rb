require "rails_helper"

describe "Address API" do
  describe "POST /address" do
    it "requires authentication" do
      post "#{host}/addresses"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      it "creates an address" do
        authenticated_post "addresses", {
          latitude: 41.233,
          longitude: 42.233,
          street_1: "A street",
          street_2: "Something special",
          city: "Testtown",
          state_code: "TT",
          zip_code: "1ABCDE",
          latest_result: "Not home",
        }, token

        expect(last_response.status).to eq 200

        new_address = Address.last

        expect(new_address.persisted?).to be true

        expect(new_address.latitude).to eq 41.233
        expect(new_address.longitude).to eq 42.233
        expect(new_address.street_1).to eq "A street"
        expect(new_address.street_2).to eq "Something special"
        expect(new_address.city).to eq "Testtown"
        expect(new_address.state_code).to eq "TT"
        expect(new_address.zip_code).to eq "1ABCDE"
      end
    end
  end

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
        it "returns 404 if the address doesn't exist" do
          get_parameters = {
            street_1: "Test street"
          }

          expected_easypost_request_parameters = {
            street1: "Test street",
            city: nil,
            state: nil,
            zip: nil
          }

          mock_verified_address = double("EasyPost::Address",
            street1: "Verified test street 1",
            street2: "Verified bonus data",
            city: "VerifiedTestTown",
            state: "VTT",
            zip: "V12345")

          expect(EasyPost::Address).to receive(:create_and_verify)
            .with(expected_easypost_request_parameters)
            .and_return(mock_verified_address)

          authenticated_get "addresses", get_parameters, token
          expect(last_response.status).to eq 404
        end

        it "returns 400 if ?"

        it "returns an existing address with people included if the address exists" do
          address = create(:address,
            id: 1,
            latitude: 1,
            longitude: 1,
            street_1: "Test street",
            street_2: "1",
            city: "Testtown",
            zip_code: "12345",
            usps_verified_street_1: "Verified test street 1",
            usps_verified_street_2: "Verified bonus data",
            usps_verified_city: "VerifiedTestTown",
            usps_verified_state: "VTT",
            usps_verified_zip: "V12345")
          person_a = create(:person, id: 5, address: address, canvas_response: :strongly_for)
          person_b = create(:person, id: 6, address: address, canvas_response: :leaning_for)

          address.people = [person_a, person_b]
          address.most_supportive_resident = person_a
          address.best_canvas_response = person_a.canvas_response
          address.save!

          get_parameters = {
            street_1: "Test street",
            street_2: "1",
            city: "TestTown",
            state_code: "TT",
            zip_code: "12345"
          }

          expected_easypost_request_parameters = {
            street1: "Test street 1",
            city: "TestTown",
            state: "TT",
            zip: "12345"
          }

          mock_verified_address = double("EasyPost::Address",
            street1: "Verified test street 1",
            street2: "Verified bonus data",
            city: "VerifiedTestTown",
            state: "VTT",
            zip: "V12345")


          expect(EasyPost::Address).to receive(:create_and_verify)
            .with(expected_easypost_request_parameters)
            .and_return(mock_verified_address)

          authenticated_get "addresses", get_parameters, token
          expect(last_response.status).to eq 200

          expect(json.data.length).to eq 1

          address_json = json.data[0]
          address_attributes = address_json.attributes
          expect(address_attributes.latitude).to eq 1.0
          expect(address_attributes.longitude).to eq 1.0
          expect(address_attributes.street_1).to eq "Test street"
          expect(address_attributes.street_2).to eq "1"
          expect(address_attributes.city).to eq "Testtown"
          expect(address_attributes.state_code).to eq "NY"
          expect(address_attributes.zip_code).to eq "12345"
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
