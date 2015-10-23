module GroundGame
  module Scenario
    class UpdateUsersFriendLeaderboard
      def initialize(friend, user)
        @user = user
        @friend = friend
      end

      def call
        @friends_leaderboard.rank_user(@user)
      end

      private

      def friends_leaderboard
        @friends_leaderboard ||= UserLeaderboard.for_friend_list_of_user(@friend)
      end
    end
  end
end
