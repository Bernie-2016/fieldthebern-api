require 'rails_helper'

describe Relationship do

  context 'schema' do
    it { should have_db_column(:follower_id).of_type(:integer) }
    it { should have_db_column(:followed_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should belong_to(:follower) }
    it { should belong_to(:followed) }
  end

  context 'validations' do
    it { should validate_presence_of(:follower) }
    it { should validate_presence_of(:followed) }
  end

  it 'cannot be declared twice for the same combination of follower and followed' do
    user_1 = create(:user)
    user_2 = create(:user)
    create(:relationship, followed: user_1, follower: user_2)
    expect{create(:relationship, followed: user_1, follower: user_2)}.to raise_error ActiveRecord::RecordNotUnique
  end
end
