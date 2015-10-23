class UpdateUsersLeaderboardsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    GroundGame::Scenario::UpdateUsersTotalScore.new(user).call
    GroundGame::Scenario::UpdateLeaderboards.new(user).call
    GroundGame::Scenario::UpdateFriendsLeaderboards.new(user).call
  end

end
