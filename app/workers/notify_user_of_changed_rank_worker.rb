require "ground_game/parse_notifier"

class NotifyUserOfChangedRankWorker
  include Sidekiq::Worker

  def perform(user_id, friend_id)
    user = User.find(user_id)
    friend = User.find(friend_id)

    GroundGame::ParseNotifier.rank_changed(user, friend)
  end
end
