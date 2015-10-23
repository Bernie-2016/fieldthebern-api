class Ranking

  DEFAULT_OPTIONS = {
    with_member_data: true
  }

  def self.for_everyone(id:, options: DEFAULT_OPTIONS)
    UserLeaderboard.for_everyone.around_me(id, options)
  end

  def self.for_state(state_code:, id:, options: DEFAULT_OPTIONS)
    UserLeaderboard.for_state(state_code).around_me(id, options)
  end

  def self.for_user_in_users_friend_list(user:, options: DEFAULT_OPTIONS)
    self.for_friend_list(list_owner: user, id: user.id)
  end

  def self.for_friend_list(list_owner:, id:, options: DEFAULT_OPTIONS)
    UserLeaderboard.for_friend_list_of_user(list_owner).around_me(id.to_s, options)
  end
end
