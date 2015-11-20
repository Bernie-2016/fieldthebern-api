require "rails_helper"
require "ground_game/scenario/update_friends_leaderboards"

module GroundGame
  module Scenario

    describe UpdateFriendsLeaderboards do
      describe "#call" do

        before do
          @user = create(:user, id: 10)
          followers = create_list(:user, 5)
          followers.each { |friend| friend.follow(@user) }
          following = create_list(:user, 5)
          following.each { |friend| @user.follow(friend) }
        end

        it "updates each of the user's followers's 'friends' leaderboard" do
          UpdateFriendsLeaderboards.new(@user).call

          @user.followers.each do |follower|
            follower_friend_leaderboard = Ranking.for_friend_list(list_owner: follower, id: @user.id)
            expect(follower_friend_leaderboard.length).to eq 1
          end
        end

        it "updates each of the user's following's 'friends' leaderboard" do
          UpdateFriendsLeaderboards.new(@user).call

          @user.following.each do |follower|
            follower_friend_leaderboard = Ranking.for_friend_list(list_owner: follower, id: @user.id)
            expect(follower_friend_leaderboard.length).to eq 1
          end
        end
      end
    end
  end
end
