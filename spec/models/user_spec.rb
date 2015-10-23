require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "is invalid without an email" do
    expect(build(:user, email: nil)).not_to be_valid
  end

  it "is invalid without a password" do
    expect(build(:user, password: nil)).not_to be_valid
  end

  it "is valid without a home_state" do
    expect(build(:user, home_state: nil)).to be_valid
  end

  it "is valid without a first_name" do
    expect(build(:user, first_name: nil)).to be_valid
  end

  it "is valid without a last_name" do
    expect(build(:user, last_name: nil)).to be_valid
  end

  it "is valid without a state_code" do
    expect(build(:user, state_code: nil)).to be_valid
  end

  it "can have followers" do
    user = create(:user)
    other_user_1 = create(:user)
    other_user_2 = create(:user)
    create(:relationship, follower: other_user_1, followed: user)
    create(:relationship, follower: other_user_2, followed: user)

    expect(user.followers.length).to eq 2
  end

  it "can have other users it follows" do
    user = create(:user)
    other_user_1 = create(:user)
    other_user_2 = create(:user)
    create(:relationship, follower: user, followed: other_user_1)
    create(:relationship, follower: user, followed: other_user_2)

    expect(user.following.length).to eq 2
  end

  it "can follow another user" do
    user = create(:user)
    other_user = create(:user)

    user.follow(other_user)
    expect(user.following? other_user).to be true
  end

  it "can unfollow another user" do
    user = create(:user)
    other_user = create(:user)
    create(:relationship, follower: user, followed: other_user)

    expect(user.following? other_user).to be true

    user.unfollow(other_user)
    expect(user.following? other_user).to be false
  end

  it "has a working 'total_points_this_week'" do
    user = create(:user)
    visits_this_week = create_list(:visit, 5, user: user, total_points: 10, created_at: Date.today)
    visits_last_week = create_list(:visit, 5, user: user, total_points: 1, created_at: Date.today - 8.days)

    expect(user.reload.total_points_this_week).to eq 50
  end
end
