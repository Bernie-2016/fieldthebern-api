module GroundGame
  module Scenario
    class UpdateUsersFriendLeaderboard
      def initialize(leaderboard_owner, user_to_rank)
        @user_to_rank = user_to_rank
        @leaderboard_owner = leaderboard_owner
      end

      def call
        old_owner_rank = leaderboard.check_user_rank(@leaderboard_owner)

        leaderboard.rank_user(@user_to_rank)

        new_owner_rank = leaderboard.check_user_rank(@leaderboard_owner)
        owner_rank_changed = old_owner_rank != new_owner_rank

        NotifyUserOfChangedRankWorker.perform_async(@leaderboard_owner.id, @user_to_rank.id) if owner_rank_changed
      end

      private

      def leaderboard
        @leaderboard ||= UserLeaderboard.for_friend_list_of_user(@leaderboard_owner)
      end
    end
  end
end
