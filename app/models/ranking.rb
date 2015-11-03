require "active_model_serializers/model"

class Ranking < ActiveModelSerializers::Model

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

  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :score, :rank, :member, :member_data

  def initialize(score: nil, rank: nil, member: nil, member_data: nil)
    @score = score
    @rank = rank
    @member = member
    @member_data = member_data
  end

  def attributes
    {
      'score' => score,
      'rank' => rank
    }
  end

  def user_id
    @member.to_i
  end

  def user
    @user ||= User.find(user_id)
  end

  def id
    @rank
  end
end