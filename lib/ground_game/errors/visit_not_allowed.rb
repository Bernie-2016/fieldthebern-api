module GroundGame
  class VisitNotAllowed < StandardError
    def initialize
      super ERROR_MESSAGE
    end
    private
      ERROR_MESSAGE = "You can't canvass the same address so soon after it was last canvassed."
  end
end
