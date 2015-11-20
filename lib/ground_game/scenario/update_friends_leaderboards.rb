require 'ground_game/scenario/update_users_friend_leaderboard'

module GroundGame
  module Scenario
    class UpdateFriendsLeaderboards
      def initialize(user)
        @user = user
        @followers = user.followers
        @following = user.following
      end

      def call
        @followers.each do |friend|
          GroundGame::Scenario::UpdateUsersFriendLeaderboard.new(friend, @user).call
        end

        @following.each do |friend|
          GroundGame::Scenario::UpdateUsersFriendLeaderboard.new(friend, @user).call
        end
      end
    end
  end
end
