require "rails_helper"
require "ground_game/scenario/update_users_total_score"

module GroundGame
  module Scenario

    describe UpdateUsersTotalScore do

      describe "#call" do
        it "sets users 'total_points' to the sum of total_points of all the user's 'visits'" do
          user = create(:user)
          create(:visit, total_points: 20, user: user)
          create(:visit, total_points: 45, user: user)
          create(:visit, total_points: 30, user: user)

          user = UpdateUsersTotalScore.new(user).call
          expect(user.changed?).to be false
          expect(user.total_points).to eq 95
        end
      end
    end
  end
end
