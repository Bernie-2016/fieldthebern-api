require "rails_helper"
require "ground_game/scenario/create_score"

module GroundGame
  module Scenario

    describe CreateScore do

      describe "#call" do
        context "when passing in a visit" do
          it "computes score and returns score" do
            visit = build(:visit)
            expect(CreateScore.new(visit: visit).call).not_to be_nil
          end
        end
      end
    end
  end
end
