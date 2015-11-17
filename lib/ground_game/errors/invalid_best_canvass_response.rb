module GroundGame
  class InvalidBestCanvassResponse < ArgumentError
    def initialize(best_canvass_response_value)
      super error_message(best_canvass_response_value)
    end

    private
      def error_message(value)
        "Invalid argument '#{value}' for address.best_canvass_response"
      end
  end
end
