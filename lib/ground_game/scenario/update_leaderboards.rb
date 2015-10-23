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

      def user_friends_leaderboard_id
        @user_friends_leaderboard_id ||= "user_#{@user.id}_friends"
      end

      def redis_options
        @redis_options ||= {redis_connection: $redis}
      end

      def everyone_leaderboard
        @everyone_leaderboard ||= Leaderboard.new('everyone', DEFAULT_OPTIONS, redis_options)
      end

      def friends_leaderboard
        @friends_leaderboard ||= Leaderboard.new(user_friends_leaderboard_id, DEFAULT_OPTIONS, redis_options)
      end

      def state_leaderboard
        @state_leaderboard ||= Leaderboard.new(@user.state_code, DEFAULT_OPTIONS, redis_options)
      end

      DEFAULT_OPTIONS = {
        :page_size => 11,
        :reverse => false,
        :member_key => :member,
        :rank_key => :rank,
        :score_key => :score,
        :member_data_key => :member_data,
        :member_data_namespace => 'member_data',
        :global_member_data => false
      }
    end
  end
end
