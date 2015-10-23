require "rails_helper"
require "ground_game/scenario/update_friends_leaderboards"

module GroundGame
  module Scenario

    describe UpdateFriendsLeaderboards do
      describe "#call" do

        before do
          @user = create(:user, id: 10)
          users_friends = create_list(:user, 5)
          users_friends.each { |friend| friend.follow(@user) }
        end

        it "updates each of the user's friend's 'friends' leaderboard" do
          UpdateFriendsLeaderboards.new(@user).call

          @user.followers.each do |follower|
            follower_friend_leaderboard = Ranking.for_friend_list(list_owner: follower, id: @user.id)
            expect(follower_friend_leaderboard.length).to eq 1
          end
        end
      end
    end
  end
end
