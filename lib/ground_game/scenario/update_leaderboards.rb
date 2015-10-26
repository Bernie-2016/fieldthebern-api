module GroundGame
  module Scenario
    class UpdateLeaderboards
      def initialize(user)
        @user = user
      end

      def call
        everyone_leaderboard.rank_user(@user)
        friends_leaderboard.rank_user(@user)
        state_leaderboard.rank_user(@user) if @user.state_code
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
