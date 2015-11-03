require "rails_helper"
require "ground_game/scenario/update_users_friend_leaderboard"
require "ground_game/parse_notification"

module GroundGame
  module Scenario

    describe UpdateUsersFriendLeaderboard do

      describe "#call" do
        before do
          @friend = create(:user, id: 11)
          friends = UserLeaderboard.for_friend_list_of_user(@friend)
          friends.rank_user(@friend)
        end

        it "updates the user's friend's 'friends' leaderboard" do
          user = create(:user, id: 10)
          UpdateUsersFriendLeaderboard.new(@friend, user).call
          rankings = Ranking.for_friend_list(list_owner: @friend, id: 10)
          expect(rankings.length).to eq 2
        end

        context "when it alters the friends rank" do
          it "sends notification to all friends devices", vcr: { cassette_name: "lib/ground_game/update_users_friend_leaderboard/when it alters the friends rank/sends notification to all friends devices" } do
            Sidekiq::Testing.inline! do
            user_with_higher_score = create(:user)
            some_other_user = create(:user)
            device_a = create(:device, user: @friend, token: "1")
            device_b = create(:device, user: @friend, token: "2")
            device_c = create(:device, user: some_other_user, token: "3")
            create(:visit, user: user_with_higher_score)

            expect(GroundGame::ParseNotification).to receive(:send).with(message: "Your friend has beaten you!", username: "1")
            expect(GroundGame::ParseNotification).to receive(:send).with(message: "Your friend has beaten you!", username: "2")
            expect(GroundGame::ParseNotification).not_to receive(:send).with(message: "Your friend has beaten you!", username: "3")
            UpdateUsersFriendLeaderboard.new(@friend, user_with_higher_score).call
          end
          end
        end
      end
    end
  end
end
