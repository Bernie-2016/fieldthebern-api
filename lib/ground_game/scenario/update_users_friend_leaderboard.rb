module GroundGame
  module Scenario
    class UpdateUsersFriendLeaderboard
      def initialize(friend, user)
        @user = user
        @friend = friend
      end

      def call
        @friends_leaderboard.rank_member(user_id_string, user_score, user_data_json)
      end

      private

      def user_score
        @user.total_points_this_week
      end

      def user_data_json
        {
          'name' => @user.first_name
        }.to_json
      end

      def user_id_string
        @user_id_string ||= @user.id.to_s
      end

      def friends_leaderboard
        @friends_leaderboard ||= ScoreLeaderboard.for_friend_list_of_user(@friend)
      end
    end
  end
end
