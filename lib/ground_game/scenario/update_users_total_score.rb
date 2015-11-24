module GroundGame
  module Scenario
    class UpdateUsersTotalScore
      def initialize(user)
        @user = user
      end

      def call
        total_points = @user.visits.sum(:total_points)
        @user.total_points = total_points
        @user.save
        
        @user
      end
    end
  end
end
