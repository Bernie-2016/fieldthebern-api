require "rails_helper"
require "ground_game/scenario/match_address"

module GroundGame
  module Scenario

    describe MatchAddressResult do
      before do
        @address = create(:address)
        @error = ArgumentError.new("A message")
      end

      describe "#success?" do
        it "returns true if there was no error" do
          expect(MatchAddressResult.new(address: @address).success?).to be true
        end
        it "returns false if there was an error" do
          expect(MatchAddressResult.new(error: @error).success?).to be false
        end
      end

    end
  end
end
