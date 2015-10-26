require 'rails_helper'

describe UpdateProfilePictureWorker do

  before do
  end

  context "when the user has 'base_64_photo_data'" do
    before do
      file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
      base_64_image = Base64.encode64(open(file) { |io| io.read })
      @user = create(:user, base_64_photo_data: base_64_image)
    end

    it "updates leaderboards" do
      expect_any_instance_of(GroundGame::Scenario::UpdateMemberDataInLeaderboards).to receive(:call)
      UpdateProfilePictureWorker.new.perform(@user.id)
    end
  end

  context "when the user does not have 'base_64_photo_data'" do
    before do
      @user = create(:user)
    end
    it "does not update leaderboards" do
      expect_any_instance_of(GroundGame::Scenario::UpdateMemberDataInLeaderboards).not_to receive(:call)
      UpdateProfilePictureWorker.new.perform(@user.id)
    end
  end
end
