require 'rails_helper'

describe Person do
  it "has a valid factory" do
    expect(build(:person)).to be_valid
  end

  it "has a working party_affiliation enum"

  it "has a working canvas_response enum"
end
