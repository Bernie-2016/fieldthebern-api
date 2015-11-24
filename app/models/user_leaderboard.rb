class UserLeaderboard < Leaderboard

  def self.for_everyone
    self.leaderboard(board_id: "everyone")
  end

  def self.for_friend_list_of_user(user)
    self.leaderboard(board_id: "user_#{user.id}_friends")
  end

  def self.for_state(state_code)
    self.leaderboard(board_id: state_code)
  end

  def self.leaderboard(board_id:)
    new(board_id, LEADERBOARD_OPTIONS, REDIS_OPTIONS)
  end

  def rank_user(user)
    rank_member(user.id.to_s, user.total_points_this_week, user.ranking_data_json)
  end

  def check_user_rank(user)
    rank_for(user.id)
  end

  def around_me(id, options = {})
    super(id.to_s, options).map { |rank_params| Ranking.new(rank_params) }
  end

  private

    REDIS_OPTIONS = {
      redis_connection: $redis
    }

    LEADERBOARD_OPTIONS = {
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
