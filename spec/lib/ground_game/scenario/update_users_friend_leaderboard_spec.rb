require "rails_helper"
require "ground_game/scenario/update_users_friend_leaderboard"

module GroundGame
  module Scenario

    describe UpdateUsersFriendLeaderboard do

      describe "#call" do
        before do
          @user = create(:user, id: 10)
          @friend = create(:user, id: 11)
          # I would love to somehow have this work with factory_girl or something similar, but I'm not sure how
          friends = UserLeaderboard.for_friend_list_of_user(@friend)
          friends.rank_user(@friend)
        end

        it "updates the user's friend's 'friends' leaderboard" do
          UpdateUsersFriendLeaderboard.new(@friend, @user).call
          rankings = Ranking.for_friend_list(list_owner: @friend, id: 10)
          expect(rankings.length).to eq 2
        end
      end
    end
  end
end
