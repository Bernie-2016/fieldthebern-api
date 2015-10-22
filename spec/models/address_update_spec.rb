require 'rails_helper'

describe AddressUpdate do
  it "has a valid factory" do
    expect(build(:address_update)).to be_valid
  end

  it "requires an 'address'" do
    expect(build(:address_update, address: nil)).not_to be_valid
  end

  it "requires a 'visit'" do
    expect(build(:address_update, visit: nil)).not_to be_valid
  end

  it "has a working 'update_type' enum" do
    address_update = create(:address_update)

    expect(address_update.created?).to be true

    address_update.modified!
    expect(address_update.modified?).to be true

    address_update.created!
    expect(address_update.created?).to be true
  end

  context "#create_for_visit_and_address" do
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
