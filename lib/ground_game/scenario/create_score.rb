module GroundGame
  module Scenario
    class CreateScore
      def initialize(visit: nil, number_of_updated_people: 0)
        @visit = visit
        @number_of_updated_people = number_of_updated_people
      end

      def call
        score = Score.new
        score.points_for_knock = 5
        score.points_for_updates = 10 * @number_of_updated_people
        score.visit = @visit
        score.save!
        score
      end
    end
  end
end
