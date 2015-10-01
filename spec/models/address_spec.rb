require 'rails_helper'

describe Address do
  it "has a valid factory" do
    expect(build(:address)).to be_valid
  end

  it "has has working result status management" do
    address = create(:address)

    expect(address.not_visited?).to be true

    address.not_home!
    expect(address.not_home?).to be true

    address.not_interested!
    expect(address.not_interested?).to be true

    address.interested!
    expect(address.interested?).to be true
  end

  it "has a working 'within' scope" do
    first_address_in_box = create(:address, coordinates: 'POINT(1 1)')
    second_address_in_box = create(:address, coordinates: 'POINT(2 2)')
    third_address_in_box = create(:address, coordinates: 'POINT(20 20)')

    addresses_in_box = Address.within(0, 0, 10, 10)
    expect(addresses_in_box).to include(first_address_in_box)
    expect(addresses_in_box).to include(second_address_in_box)
    expect(addresses_in_box).not_to include(third_address_in_box)
  end
end
