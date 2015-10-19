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

        it "gives 5 points for a visit with no updated people" do
          visit = build(:visit)
          score = CreateScore.new(visit: visit, number_of_updated_people: 0).call
          expect(score.total_points).to eq 5
        end
        it "gives 10 points per updated or added person" do
          visit = build(:visit)

          score = CreateScore.new(visit: visit, number_of_updated_people: 1).call
          expect(score.total_points).to eq 15

          score = CreateScore.new(visit: visit, number_of_updated_people: 2).call
          expect(score.total_points).to eq 25
        end
      end
    end
  end
end
