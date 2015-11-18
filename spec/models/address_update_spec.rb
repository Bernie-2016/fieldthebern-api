require 'rails_helper'

describe AddressUpdate do
  it 'has a valid factory' do
    expect(build(:address_update)).to be_valid
  end

  context 'schema' do
    it {should have_db_column(:address_id).of_type(:integer) }
    it {should have_db_column(:visit_id).of_type(:integer) }
    it {should have_db_column(:update_type).of_type(:string).with_options(default: 'created') }

    it {should have_db_column(:old_latitude).of_type(:float) }
    it {should have_db_column(:old_longitude).of_type(:float) }
    it {should have_db_column(:old_street_1).of_type(:string) }
    it {should have_db_column(:old_street_2).of_type(:string) }
    it {should have_db_column(:old_city).of_type(:string) }
    it {should have_db_column(:old_state_code).of_type(:string) }
    it {should have_db_column(:old_zip_code).of_type(:string) }
    it {should have_db_column(:old_visited_at).of_type(:datetime) }
    it {should have_db_column(:old_most_supportive_resident_id).of_type(:integer) }
    it {should have_db_column(:old_best_canvass_response).of_type(:string) }

    it {should have_db_column(:new_latitude).of_type(:float) }
    it {should have_db_column(:new_longitude).of_type(:float) }
    it {should have_db_column(:new_street_1).of_type(:string) }
    it {should have_db_column(:new_street_2).of_type(:string) }
    it {should have_db_column(:new_city).of_type(:string) }
    it {should have_db_column(:new_state_code).of_type(:string) }
    it {should have_db_column(:new_zip_code).of_type(:string) }
    it {should have_db_column(:new_visited_at).of_type(:datetime) }
    it {should have_db_column(:new_most_supportive_resident_id).of_type(:integer) }
    it {should have_db_column(:new_best_canvass_response).of_type(:string) }
  end

  context 'associations' do
    it { should belong_to(:address) }
    it { should belong_to(:visit) }
  end

  context 'validations' do
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:visit) }
  end

  it "has a working 'update_type' enum" do
    address_update = create(:address_update)

    expect(address_update.created?).to be true

    address_update.modified!
    expect(address_update.modified?).to be true

    address_update.created!
    expect(address_update.created?).to be true
  end

  describe ".create_for_visit_and_address" do
    it "creates an update with 'created' type if address is a new record" do
      visit = create(:visit)
      address = build(:address)
      address_update = AddressUpdate.create_for_visit_and_address(visit, address)
      expect(address_update.created?).to be true
    end

    it "creates an update with 'modified' type if address is an existing record" do
      visit = create(:visit)
      address = create(:address)
      address_update = AddressUpdate.create_for_visit_and_address(visit, address)
      expect(address_update.modified?).to be true
    end

    it "sets old_ and new_ fields to proper values" do
      create(:person, id: 1)
      create(:person, id: 2)

      visit = create(:visit)
      address = create(:address,
        latitude: 2,
        longitude: 3,
        street_1: 'Old street 1',
        street_2: 'Old street 2',
        city: 'Old city',
        state_code: 'Old state code',
        zip_code: 'Old zip code',
        visited_at: DateTime.new(2014, 1, 2, 3, 4, 5),
        most_supportive_resident_id: 1,
        best_canvass_response: "leaning_against")

      address.assign_attributes(
        latitude: 4,
        longitude: 5,
        street_1: 'New street 1',
        street_2: 'New street 2',
        city: 'New city',
        state_code: 'New state code',
        zip_code: 'New zip code',
        visited_at: DateTime.new(2015, 1, 2, 3, 4, 5),
        most_supportive_resident_id: 2,
        best_canvass_response: "strongly_for")

      address_update = AddressUpdate.create_for_visit_and_address(visit, address)

      expect(address_update.old_latitude).to eq 2
      expect(address_update.old_longitude).to eq 3
      expect(address_update.old_street_1).to eq "Old street 1"
      expect(address_update.old_street_2).to eq "Old street 2"
      expect(address_update.old_city).to eq "Old city"
      expect(address_update.old_state_code).to eq "Old state code"
      expect(address_update.old_zip_code).to eq "Old zip code"
      expect(address_update.old_visited_at).to eq DateTime.new(2014, 1, 2, 3, 4, 5)
      expect(address_update.old_most_supportive_resident_id).to eq 1
      expect(address_update.old_best_canvass_response).to eq "leaning_against"

      expect(address_update.new_latitude).to eq 4
      expect(address_update.new_longitude).to eq 5
      expect(address_update.new_street_1).to eq "New street 1"
      expect(address_update.new_street_2).to eq "New street 2"
      expect(address_update.new_city).to eq "New city"
      expect(address_update.new_state_code).to eq "New state code"
      expect(address_update.new_zip_code).to eq "New zip code"
      expect(address_update.new_visited_at).to eq DateTime.new(2015, 1, 2, 3, 4, 5)
      expect(address_update.new_most_supportive_resident_id).to eq 2
      expect(address_update.new_best_canvass_response).to eq "strongly_for"
    end
  end
end
