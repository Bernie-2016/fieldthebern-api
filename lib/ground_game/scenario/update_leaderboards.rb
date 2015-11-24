require 'ground_game/scenario/update_users_friend_leaderboard'

module GroundGame
  module Scenario
    class UpdateLeaderboards
      def initialize(user)
        @user = user
      end

      def call
        everyone_leaderboard.rank_user(@user)
        state_leaderboard.rank_user(@user) if @user.state_code

        friends_leaderboard.rank_user(@user)
        @user.followers.each do |friend|
          friends_leaderboard.rank_user(friend)
        end
      end

      private

      def everyone_leaderboard
        @everyone_leaderboard ||= UserLeaderboard.for_everyone
      end

      def friends_leaderboard
        @friends_leaderboard ||= UserLeaderboard.for_friend_list_of_user(@user)
      end

      def state_leaderboard
        @state_leaderboard ||= UserLeaderboard.for_state(@user.state_code)
      end
    end
  end
end
