require 'rails_helper'

describe Visit do
  it "has a valid factory" do
    expect(build(:visit)).to be_valid
  end

  it "requires a user" do
    expect(build(:visit, user: nil)).not_to be_valid
  end

  it "supports timestaps" do
    visit = create(:visit)
    expect(visit.created_at).not_to be_nil
  end

  it "has a working 'this_week' scope" do
    user = create(:user)
    visits_this_week = create_list(:visit, 7, user: user, total_points: 10, created_at: Time.now)
    visits_last_week = create_list(:visit, 5, user: user, total_points: 1, created_at: Time.now - 8.days)

    expect(Visit.this_week.count).to eq 7
  end
end
