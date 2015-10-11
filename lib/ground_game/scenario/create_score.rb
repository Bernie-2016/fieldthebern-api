module GroundGame
  module Scenario
    class CreateScore
      def initialize(visit: nil)
        @visit = visit
      end

      def call
        # TODO: Returns a scalar for now.
        # Should eventually return a Score record, which includes a total_points property
        # The formula is arbitrary as well
        if @visit.duration_sec < 600
          600 - @visit.duration_sec
        else
          0
        end
      end
    end
  end
end
