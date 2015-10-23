module GroundGame
  module Scenario
    class UpdateUsersFriendLeaderboard
      def initialize(friend, user)
        @user = user
        user_friends_leaderboard = "user_#{friend.id}_friends"
        @friends = Leaderboard.new(user_friends_leaderboard, DEFAULT_OPTIONS, redis_options)
        @user_id_string = user.id.to_s
      end

      def call
        @friends.rank_member(@user_id_string, user_score, user_data_json)
      end

      private

      def user_score
        @user.visits.where(
          created_at: today.at_beginning_of_week..today.at_end_of_week
        ).sum(:total_points)
      end

      def today
        Date.today
      end

      def user_data_json
        {
          'name' => @user.first_name
        }.to_json
      end

      def redis_options
        @redis_options ||= {redis_connection: $redis}
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
