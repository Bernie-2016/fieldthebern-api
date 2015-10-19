module GroundGame
  module Scenario
    class CreateScore
      def initialize(visit: nil, num_of_updated_people: 0)
        @visit = visit
        @num_of_updated_people = num_of_updated_people
      end

      def call
        score = Score.new
        score.points_for_knock = 5
        score.points_for_updates = 10 * @num_of_updated_people
        score.visit = @visit
        score.save!
        score
      end
    end
  end
end
