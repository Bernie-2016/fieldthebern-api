require 'rails_helper'

describe AddressUpdate do
  it 'has a valid factory' do
    expect(build(:address_update)).to be_valid
  end

  context 'schema' do
    it {should have_db_column(:address_id).of_type(:integer) }
    it {should have_db_column(:visit_id).of_type(:integer) }
    it {should have_db_column(:update_type).of_type(:string).with_options(default: 'created') }
    it { should have_db_column(:created_at).of_type(:datetime) }
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
  end
end
