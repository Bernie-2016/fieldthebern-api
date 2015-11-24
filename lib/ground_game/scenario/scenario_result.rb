require "ground_game/scenario/scenario_error"

module GroundGame
  module Scenario
    class ScenarioResult
      def initialize(result: nil, error: nil)
        @result = result
        @error = ScenarioError.new(error) unless error.nil?
      end

      def error
        @error
      end

      def success?
        @error.nil?
      end
    end
  end
end
