require 'rails_helper'

describe Visit do
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
end
