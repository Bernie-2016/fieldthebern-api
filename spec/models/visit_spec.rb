require 'rails_helper'

describe Address do
  it "has a valid factory" do
    expect(build(:visit)).to be_valid
  end

  it "requires a user" do
    expect(build(:visit, user: nil)).not_to be_valid
  end

  it "requires an address" do
    expect(build(:visit, address: nil)).not_to be_valid
  end

  it "supports timestaps" do
    visit = create(:visit)
    expect(visit.created_at).not_to be_nil
  end

  it "has has working result status management" do
    visit = create(:visit)

    expect(visit.not_visited?).to be true

    visit.not_home!
    expect(visit.not_home?).to be true

    visit.not_interested!
    expect(visit.not_interested?).to be true

    visit.interested!
    expect(visit.interested?).to be true

    visit.unsure!
    expect(visit.unsure?).to be true
  end
end
