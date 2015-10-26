require 'rails_helper'

describe AddFacebookProfilePicture ,vcr: { cassette_name: 'workers/add profile pic/add_profile_pic_from_facebook' } do

  before do
    oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
    test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
    @facebook_user = test_users.create(true, "email,user_friends")
  end

  context "when user already has a photo" do
    before do
      @user = create(:user, :with_a_photo, facebook_id: @facebook_user["id"], facebook_access_token: @facebook_user["access_token"])
    end

    it "doesn't modify the photo" do
      AddFacebookProfilePicture.new.perform(@user.id)
      @user.reload
      expect(@user.photo.path).to include "original.png"
    end
  end

  context "when user doesn't have a photo" do
    before do
      @user = create(:user, facebook_id: @facebook_user["id"], facebook_access_token: @facebook_user["access_token"])
    end

    it "adds a profile picture from facebook" do
      AddFacebookProfilePicture.new.perform(@user.id)
      @user.reload
      expect(@user.photo.path).not_to be_nil
      expect(@user.photo.path).not_to include "original.png"
    end
  end
end
