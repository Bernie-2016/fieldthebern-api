module GroundGame
  module Scenario
    class UpdateLeaderboards
      def initialize(user)
        @user = user
      end

      def call
        everyone_leaderboard.rank_member(user_id_string, user_score, user_data_json)
        friends_leaderboard.rank_member(user_id_string, user_score, user_data_json)
        state_leaderboard.rank_member(user_id_string, user_score, user_data_json)
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

      def everyone_leaderboard
        @everyone_leaderboard ||= ScoreLeaderboard.for_everyone
      end

      def friends_leaderboard
        @friends_leaderboard ||= ScoreLeaderboard.for_friend_list_of_user(@user)
      end

      def state_leaderboard
        @state_leaderboard ||= ScoreLeaderboard.for_state(@user.state_code)
      end
    end
  end
end
