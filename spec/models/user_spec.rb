require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end
  it "is invalid without a first name" do
    expect(build(:user, first_name: nil)).not_to be_valid
  end

  it "is invalid without a last name" do
    expect(build(:user, last_name: nil)).not_to be_valid
  end
end
