require "rails_helper"
require "ground_game/scenario/update_leaderboards"

module GroundGame
  module Scenario

    describe UpdateLeaderboards do

      describe "#call" do
        it "updates the 'everyone' leaderboard"
        it "updates the user's 'state' leaderboard"
        it "updates the user's 'friends' leaderboard"
      end
    end
  end
end
