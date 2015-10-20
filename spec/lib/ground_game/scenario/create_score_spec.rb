require "rails_helper"
require "ground_game/scenario/create_score"

module GroundGame
  module Scenario

    describe CreateScore do

      describe "#call" do
        it "computes and returns a Score and associates it with visit" do
          visit = build(:visit)
          score = CreateScore.new(visit).call
          expect(score).to be_a Score
          expect(score.visit).to eq visit
        end

        it "gives 5 points for a visit with no updated people" do
          visit = build(:visit, people_count: 0)
          score = CreateScore.new(visit).call
          expect(score.total_points).to eq 5
        end
        it "gives 10 points per updated or added person" do
          visit_with_1_person = build(:visit, people_count: 1)
          score = CreateScore.new(visit_with_1_person).call
          expect(score.total_points).to eq 15

          visit_with_2_people = build(:visit, people_count: 2)
          score = CreateScore.new(visit_with_2_people).call
          expect(score.total_points).to eq 25
        end
      end
    end
  end
end
