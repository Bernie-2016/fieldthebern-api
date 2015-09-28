require 'rails_helper'

describe Relationship do
  it 'is invalid without a follower' do
    user_1 = create(:user)
    expect(build(:relationship, follower: nil, followed: user_1)).not_to be_valid
  end

  it 'is invalid without a followed user' do
    user_1 = create(:user)
    expect(build(:relationship, followed: nil, follower: user_1)).not_to be_valid
  end

  it 'is valid with a follower and followed user' do
    user_1 = create(:user)
    user_2 = create(:user)
    expect(build(:relationship, followed: user_1, follower: user_2)).to be_valid
  end

  it 'cannot be declared twice for the same combination of follower and followed' do
    user_1 = create(:user)
    user_2 = create(:user)
    relationship = create(:relationship, followed: user_1, follower: user_2)

    expect{create(:relationship, followed: user_1, follower: user_2)}.to raise_error ActiveRecord::RecordNotUnique
  end
end
