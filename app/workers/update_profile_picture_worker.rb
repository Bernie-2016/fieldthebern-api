require "ground_game/scenario/update_member_data_in_leaderboards"

class UpdateProfilePictureWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    return unless user.base_64_photo_data
    user.decode_image_data
    user.base_64_photo_data = nil
    if user.save
      GroundGame::Scenario::UpdateMemberDataInLeaderboards.new(user).call
    end
  end
end
