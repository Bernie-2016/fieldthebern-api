require 'rails_helper'

describe UpdateProfilePictureWorker do

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

    it "sets 'photo', then unsets 'base_64_photo_data'" do
      UpdateProfilePictureWorker.new.perform(@user.id)

      @user.reload
      expect(@user.photo.to_s).not_to eq "https://s3.amazonaws.com/ground-game/icons/default_original.png"
      expect(@user.photo.to_s).not_to be_nil
      expect(@user.base_64_photo_data).to be_nil
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

    it "doesn't touch photo" do
      UpdateProfilePictureWorker.new.perform(@user.id)

      @user.reload
      expect(@user.photo.to_s).to eq "https://s3.amazonaws.com/ground-game/icons/default_original.png"
    end
  end
end
