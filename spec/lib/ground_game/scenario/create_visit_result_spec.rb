require "rails_helper"
require "ground_game/scenario/create_visit"

module GroundGame
  module Scenario

    describe CreateVisitResult do
      before do
        @visit = create(:visit)
        @error = ArgumentError.new("A message")
      end

      describe "#success?" do
        it "returns true if there was no error" do
          expect(CreateVisitResult.new(visit: @visit).success?).to be true
        end
        it "returns false if there was an error" do
          expect(CreateVisitResult.new(error: @error).success?).to be false
        end
      end

    end
  end
end
