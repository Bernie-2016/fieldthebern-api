module GroundGame
  module Scenario
    class UpdateUsersFriendLeaderboard
      def initialize(friend, user)
        @user = user
        @friend = friend
      end

      def call
        old_friend_rank = friends_leaderboard.check_user_rank(@friend)
        friends_leaderboard.rank_user(@user)
        new_friend_rank = friends_leaderboard.check_user_rank(@friend)
        rank_changed = old_friend_rank != new_friend_rank
        NotifyUserOfChangedRankWorker.perform_async(@friend.id, @user.id) if rank_changed
      end

      private

      def friends_leaderboard
        @friends_leaderboard ||= UserLeaderboard.for_friend_list_of_user(@friend)
      end
    end
  end
end
