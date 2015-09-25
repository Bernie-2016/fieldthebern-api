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

  it "can have followers" do
    user = create(:user)
    other_user_1 = create(:user)
    other_user_2 = create(:user)
    relationship = create(:relationship, follower: other_user_1, followed: user)
    relationship = create(:relationship, follower: other_user_2, followed: user)

    expect(user.followers.length).to eq 2
  end

  it "can have other users it follows" do
    user = create(:user)
    other_user_1 = create(:user)
    other_user_2 = create(:user)
    relationship = create(:relationship, follower: user, followed: other_user_1)
    relationship = create(:relationship, follower: user, followed: other_user_2)

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
    relationship = create(:relationship, follower: user, followed: other_user)

    expect(user.following? other_user).to be true

    user.unfollow(other_user)
    expect(user.following? other_user).to be false
  end
end
