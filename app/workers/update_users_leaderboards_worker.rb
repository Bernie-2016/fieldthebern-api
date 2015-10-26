require 'ground_game/scenario/update_users_total_score'
require 'ground_game/scenario/update_leaderboards'
require 'ground_game/scenario/update_friends_leaderboards'

class UpdateUsersLeaderboardsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    GroundGame::Scenario::UpdateUsersTotalScore.new(user).call
    GroundGame::Scenario::UpdateLeaderboards.new(user).call
    GroundGame::Scenario::UpdateFriendsLeaderboards.new(user).call
  end

end
