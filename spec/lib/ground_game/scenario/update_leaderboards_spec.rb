require "rails_helper"
require "ground_game/scenario/update_leaderboards"

module GroundGame
  module Scenario

    describe UpdateLeaderboards do

      describe "#call" do
        context "when the user has all the required information" do

          before do
            @user = create(:user, id: 10, email: "test-user@mail.com", password: "password", state_code: "NY")
          end

          it "updates the 'everyone' leaderboard" do
            everyone = UserLeaderboard.for_everyone
            3.times { |n| everyone.rank_member(n.to_s, n) }

            UpdateLeaderboards.new(@user).call

            everyone_rankings = Ranking.for_everyone(id: 10)
            expect(everyone_rankings.length).to eq 4 # 3 from before plus 1 new
          end

          it "updates the user's 'state' leaderboard" do
            state_ny = UserLeaderboard.for_state("NY")
            2.times { |n| state_ny.rank_member(n.to_s, n) }

            UpdateLeaderboards.new(@user).call

            ny_rankings = Ranking.for_state(id: 10, state_code: "NY")
            expect(ny_rankings.length).to eq 3 # 2 from before plus 1 new
          end

          it "updates the user's 'friends' leaderboard" do
            followers = create_list(:user, 5)
            followers.each { |follower| follower.follow(@user) }

            UpdateLeaderboards.new(@user).call

            friend_rankings = Ranking.for_user_in_users_friend_list(user: @user)
            expect(friend_rankings.length).to eq 6 # 5 followers plus user
          end
        end

        context "when the user doesn't have a state code" do
          before do
            @user_without_state = create(:user, id: 11, email: "test-user@mail.com", password: "password", state_code: nil)
          end

          it "should not update any 'state' leaderboard" do
            expect(UserLeaderboard).not_to receive(:for_state)
            UpdateLeaderboards.new(@user_without_state).call
          end
        end
      end
    end
  end
end
