module GroundGame
  class VisitNotAllowed < StandardError
    def initialize
      super ERROR_MESSAGE
    end
    private
      ERROR_MESSAGE = "You can't submit the same address so quickly after it was last visited."
  end
end
