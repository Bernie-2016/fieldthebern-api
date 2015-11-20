module GroundGame
  class EasyPostErrorAdapter

    attr_reader :detail, :id, :title, :status

    def initialize(error)
      @error = error
      @detail = compute_detail
      @id = compute_id
      @title = compute_title
      @status = compute_status
    end

    private
      def compute_detail
        message = @error.message
        LEADING_STRINGS_TO_REMOVE.each do |string|
          message.sub!(string + ": ", "")
        end
        message
      end

      LEADING_STRINGS_TO_REMOVE = [
        "Default address"
      ]

      CODE_TO_ID = {
        "ADDRESS.VERIFY.FAILURE" => "EASYPOST_ADDRESS_VERIFICATION_ERROR"
      }

      UNKNOWN_ID = "EASYPOST_UNKNOWN_ERROR"

      def compute_id
        CODE_TO_ID[@error.code] || UNKNOWN_ID
      end

      CODE_TO_TITLE = {
        "ADDRESS.VERIFY.FAILURE" => "Unable to verify address"
      }

      UNKNOWN_TITLE = "Unknown address error"

      def compute_title
        CODE_TO_TITLE[@error.code] || UNKNOWN_TITLE
      end

      def compute_status
        @error.http_status
      end
  end
end
