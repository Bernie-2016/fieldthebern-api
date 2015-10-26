require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  context 'schema' do
    it { should have_db_column(:first_name).of_type(:string) }
    it { should have_db_column(:last_name).of_type(:string) }
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:encrypted_password).of_type(:string) }
    it { should have_db_column(:confirmation_token).of_type(:string) }
    it { should have_db_column(:remember_token).of_type(:string) }
    it { should have_db_column(:facebook_id).of_type(:string) }
    it { should have_db_column(:facebook_access_token).of_type(:text) }
    it { should have_db_column(:home_state).of_type(:string) }
    it { should have_db_column(:total_points).of_type(:integer) }
    it { should have_db_column(:state_code).of_type(:string) }
    it { should have_db_column(:photo_file_name).of_type(:string) }
    it { should have_db_column(:photo_content_type).of_type(:string) }
    it { should have_db_column(:photo_file_size).of_type(:integer) }
    it { should have_db_column(:photo_updated_at).of_type(:datetime) }
    it { should have_db_column(:visits_count).of_type(:integer) }
  end

  context 'associations' do
    it { should have_many(:visits) }
    it { should have_many(:active_relationships) }
    it { should have_many(:passive_relationships) }
    it { should have_many(:followers) }
    it { should have_many(:following) }
  end

  context 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:facebook_id).allow_nil }
  end

  context 'paperclip' do
    it { should have_attached_file(:photo) }
    it { should validate_attachment_content_type(:photo)
        .allowing('image/png', 'image/gif')
        .rejecting('text/plain', 'text/xml') }
  end

  context 'following behavior' do
    before(:each) do
      @user = create(:user)
      @other_user_1 = create(:user)
      @other_user_2 = create(:user)
    end

    it "can have followers" do
      create(:relationship, follower: @other_user_1, followed: @user)
      create(:relationship, follower: @other_user_2, followed: @user)

      expect(@user.followers.length).to eq 2
    end

    it "can have other users it follows" do
      create(:relationship, follower: @user, followed: @other_user_1)
      create(:relationship, follower: @user, followed: @other_user_2)

      expect(@user.following.length).to eq 2
    end

    it "can follow another user" do
      @user.follow(@other_user_1)
      expect(@user.following? @other_user_1).to be true
    end

    it "can unfollow another user" do
      create(:relationship, follower: @user, followed: @other_user_1)
      @user.unfollow(@other_user_1)
      expect(@user.following? @other_user_1).to be false
    end
  end

  it "is invalid with a duplicate email" do
    create(:user, email: "existing-email@mail.com")
    expect(build(:user, email: "existing-email@mail.com")).not_to be_valid
  end

  it "can have followers" do
    user = create(:user)
    other_user_1 = create(:user)
    other_user_2 = create(:user)
    create(:relationship, follower: other_user_1, followed: user)
    create(:relationship, follower: other_user_2, followed: user)
  end

  context 'leaderboard' do
    before(:each) do
      @user = create(:user)
    end
    it "has a working 'total_points_this_week'" do
      visits_this_week = create_list(:visit, 5, user: @user, total_points: 10, created_at: Time.now)
      visits_last_week = create_list(:visit, 5, user: @user, total_points: 1, created_at: Time.now - 8.days)

      expect(@user.reload.total_points_this_week).to eq 50
    end
  end

  context 'instance methods' do
    before (:each) do
      @user = create(:user)
    end

    it 'should have a #full_name' do
      expect(@user.full_name).to eq 'John Doe'
    end

    it 'should have a #ranking_name identical to its full name when first and last are present' do
      expect(@user.ranking_name).to eq 'John Doe'
    end

    it 'should have a #ranking_name derived from its email when first and last are not present' do
      @user.first_name = @user.last_name = nil
      expect(@user.email).to include @user.ranking_name
    end

    it 'should have a #ranking_data_json that includes ranking name and thumbnail photo' do
      expect(@user.ranking_data_json).to include @user.ranking_name
      expect(@user.ranking_data_json).to include @user.photo.url(:thumb)
    end
  end

  it 'has a counter cache from visits' do
    @user = create(:user)
    expect { @user.visits.create }.to change { @user.visits_count }.by(1)
  end
end
