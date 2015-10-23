class RankingsController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    id = current_user.id.to_s

    if params[:type] == "everyone"
      rankings = everyone.around_me(id, leaderboard_options)
      render json: rankings
    elsif params[:type] == "state"
      if current_user.state_code
        rankings = state(
          state_code: current_user.state_code
        ).around_me(id, leaderboard_options)
        render json: rankings
      end
    elsif params[:type] == "friends"
      rankings = friends.around_me(id, leaderboard_options)
      render json: rankings
    end
  end

  # def index_params
  #   latitude = params.require(:latitude)
  #   longitude = params.require(:longitude)
  #   radius = params.require(:radius)
  #   { latitude: latitude, longitude: longitude, radius: radius }
  # end

  private

    def redis_options
      @redis_options ||= {redis_connection: $redis}
    end

    def everyone
      @everyone ||= Leaderboard.new('everyone', DEFAULT_OPTIONS, redis_options)
    end

    def state(state_code:)
      Leaderboard.new(state_code, DEFAULT_OPTIONS, redis_options)
    end

    def friends
      Leaderboard.new("user_#{current_user.id}_friends", DEFAULT_OPTIONS, redis_options)
    end

    def leaderboard_options
      {with_member_data: true}
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
