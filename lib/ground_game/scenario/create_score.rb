module GroundGame
  module Scenario
    class CreateScore
      def initialize(visit: nil)
        @visit = visit
      end

      def call
        score = Score.new
        score.points_for_knock = 5
        score.points_for_updates = 10 * @visit.people.count
        score.visit = @visit
        score.save!
        score
      end
    end
  end
end
