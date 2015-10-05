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
    first_address_in_radius = create(:address, latitude: 1, longitude: 1)
    second_address_in_radius = create(:address, latitude: -1, longitude: -1)
    third_address_outside_radius = create(:address, latitude: 20, longitude: 20)

    addresses_in_radius = Address.within(400 * 1000, origin: [0, 0]) # 400 km distance
    expect(addresses_in_radius).to include(first_address_in_radius)
    expect(addresses_in_radius).to include(second_address_in_radius)
    expect(addresses_in_radius).not_to include(third_address_outside_radius)
  end
end
