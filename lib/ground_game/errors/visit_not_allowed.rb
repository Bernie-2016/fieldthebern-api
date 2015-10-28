module GroundGame
  class VisitNotAllowed < StandardError
    def initialize
      super ERROR_MESSAGE
    end
    private
      ERROR_MESSAGE = "You cannot visit this address so soon since it was last visited"
  end
end
