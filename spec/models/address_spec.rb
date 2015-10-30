require 'rails_helper'

describe Address do
  it "has a valid factory" do
    expect(build(:address)).to be_valid
  end

  context 'schema' do
    it {should have_db_column(:latitude).of_type(:float) }
    it {should have_db_column(:longitude).of_type(:float) }
    it {should have_db_column(:street_1).of_type(:string) }
    it {should have_db_column(:street_2).of_type(:string) }
    it {should have_db_column(:city).of_type(:string) }
    it {should have_db_column(:state_code).of_type(:string) }
    it {should have_db_column(:zip_code).of_type(:string) }
    it {should have_db_column(:visited_at).of_type(:datetime) }
    it {should have_db_column(:most_supportive_resident_id).of_type(:integer) }
    it {should have_db_column(:usps_verified_street_1).of_type(:string) }
    it {should have_db_column(:usps_verified_city).of_type(:string) }
    it {should have_db_column(:usps_verified_zip).of_type(:string) }
    it {should have_db_column(:best_canvas_response).of_type(:string) }
  end

  context 'associations' do
    it { should have_many(:people) }
    it { should belong_to(:most_supportive_resident) }
  end

  context 'validations' do
    it { should validate_presence_of(:state_code) }
  end

  context 'scopes' do
    it "has a working 'within' scope" do
      first_address_in_radius = create(:address, latitude: 1, longitude: 1)
      second_address_in_radius = create(:address, latitude: -1, longitude: -1)
      third_address_outside_radius = create(:address, latitude: 20, longitude: 20)

      addresses_in_radius = Address.within(400 * 1000, origin: [0, 0]) # 400 km distance
      expect(addresses_in_radius).to include(first_address_in_radius)
      expect(addresses_in_radius).to include(second_address_in_radius)
      expect(addresses_in_radius).not_to include(third_address_outside_radius)
    end
  end

  it "has a working 'best_canvas_response' enum" do
    address = create(:address)

    expect(address.not_yet_visited?).to be true

    address.not_home!
    expect(address.not_home?).to be true

    address.unknown!
    expect(address.unknown?).to be true

    address.strongly_for!
    expect(address.strongly_for?).to be true

    address.leaning_for!
    expect(address.leaning_for?).to be true

    address.undecided!
    expect(address.undecided?).to be true

    address.leaning_against!
    expect(address.leaning_against?).to be true

    address.strongly_against!
    expect(address.strongly_against?).to be true

    address.asked_to_leave!
    expect(address.asked_to_leave?).to be true
  end

  describe "#assign_most_supportive_resident" do
    it "assigns person as most supportive resident and persons canvas_response as best_canvas_response" do
      address = create(:address)
      person = create(:person, canvas_response: :strongly_for)

      address.assign_most_supportive_resident(person)

      expect(address.most_supportive_resident).to eq person
      expect(address.best_canvas_response).to eq person.canvas_response
    end
  end

  describe ".new_or_existing_from_params" do
    it "initializes a new address if the params do not contain an id", vcr: { cassette_name: "models/address/creates_a_new_address_if_the_params_do_not_contain_an_id" } do
      expect(Address.count).to eq 0
      params = {
        latitude: 1,
        longitude: 1
      }
      address = Address.new_or_existing_from_params(params)
      expect(address.persisted?).to be false
    end
    it "fetches and updates (without save) an existing address if the params do contain an id" do
      create(:address, id: 1, latitude: 0, longitude: 0)
      params = {
        id: 1,
        latitude: 1,
        longitude: 1
      }
      address = Address.new_or_existing_from_params(params)
      expect(Address.count).to eq 1
      expect(address.changed?).to be true
      expect(address.latitude).to eq 1
      expect(address.longitude).to eq 1
    end

    it "should raise an error if there's an invalid 'best_canvas_response' parameter value" do
      create(:address, id: 1, latitude: 0, longitude: 0)
      params = {
        id: 1,
        best_canvas_response: "strongly_for"
      }
      expect { Address.new_or_existing_from_params(params) }.to raise_error ArgumentError
    end
  end
end
