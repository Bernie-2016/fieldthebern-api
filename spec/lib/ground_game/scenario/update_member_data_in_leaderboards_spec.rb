require "rails_helper"
require "ground_game/scenario/update_member_data_in_leaderboards"

module GroundGame
  module Scenario

    describe UpdateMemberDataInLeaderboards do

      describe "#call" do

        context "when the user has all the required information" do
          before do
            @user = create(:user, id: 10, email: "test-user@mail.com", password: "password", state_code: "NY")

            # I would love to somehow have this work with factory_girl or something similar, but I'm not sure how

            everyone = UserLeaderboard.for_everyone
            3.times { |n| everyone.rank_member(n.to_s, n) }

            state_ny = UserLeaderboard.for_state("NY")
            2.times { |n| state_ny.rank_member(n.to_s, n) }

            friends = UserLeaderboard.for_friend_list_of_user(@user)
            5.times { |n| friends.rank_member(n.to_s, n) }
          end

          it "updates the 'everyone' leaderboard" do
            UpdateMemberDataInLeaderboards.new(@user).call

            everyone_rankings = Ranking.for_everyone(id: 10)
            expect(everyone_rankings.length).to eq 4
          end

          it "updates the user's 'state' leaderboard" do
            UpdateMemberDataInLeaderboards.new(@user).call

            ny_rankings = Ranking.for_state(id: 10, state_code: "NY")
            expect(ny_rankings.length).to eq 3
          end

          it "updates the user's 'friends' leaderboard" do
            UpdateMemberDataInLeaderboards.new(@user).call

            friend_rankings = Ranking.for_user_in_users_friend_list(user: @user)
            expect(friend_rankings.length).to eq 6
          end
        end

        context "when the user doesn't have a state code" do
          before do
            @user_without_state = create(:user, id: 11, email: "test-user@mail.com", password: "password", state_code: nil)
          end

          it "should not update any 'state' leaderboard" do
            expect(UserLeaderboard).not_to receive(:for_state)
            UpdateMemberDataInLeaderboards.new(@user_without_state).call
          end
        end
      end
    end
  end
end
