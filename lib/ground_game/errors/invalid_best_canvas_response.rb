module GroundGame
  class InvalidBestCanvasResponse < ArgumentError
    def initialize(best_canvas_response_value)
      super error_message(best_canvas_response_value)
    end

    private
      def error_message(value)
        "Invalid argument '#{value}' for address.best_canvas_response"
      end
  end
end
