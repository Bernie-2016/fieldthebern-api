require "rails_helper"
require "ground_game/scenario/create_score"

module GroundGame
  module Scenario

    describe CreateScore do

      describe "#call" do
        it "computes and returns a Score and associates it with visit" do
          visit = build(:visit)
          score = CreateScore.new(visit: visit).call
          expect(score).to be_a Score
          expect(score.visit).to eq visit
        end

        it "gives 5 points for a visit with no updated people"
        it "gives 10 points per updated or added person"
      end
    end
  end
end
