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
end
