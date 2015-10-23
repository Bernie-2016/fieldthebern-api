class ScoreLeaderboard

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
    Leaderboard.new(board_id, LEADERBOARD_OPTIONS, REDIS_OPTIONS)
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
