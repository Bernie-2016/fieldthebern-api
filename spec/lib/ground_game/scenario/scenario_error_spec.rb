require "rails_helper"
require "ground_game/scenario/scenario_error"

module GroundGame
  module Scenario

    describe ScenarioError do
      before do
        @record_not_found_error = ActiveRecord::RecordNotFound.new("A message")
      end

      it "maps ArgumentError correctly" do
        argument_error = ArgumentError.new("A message")
        error = ScenarioError.new(argument_error)
        expect(error.id).to eq "ARGUMENT_ERROR"
        expect(error.title).to eq "Argument error"
        expect(error.detail).to eq "A message"
        expect(error.status).to eq 422
      end

      it "maps ActiveRecord::RecordNotFound correctly" do
        argument_error = ActiveRecord::RecordNotFound.new("A message")
        error = ScenarioError.new(argument_error)
        expect(error.id).to eq "RECORD_NOT_FOUND"
        expect(error.title).to eq "Record not found"
        expect(error.detail).to eq "A message"
        expect(error.status).to eq 404
      end
    end
  end
end
