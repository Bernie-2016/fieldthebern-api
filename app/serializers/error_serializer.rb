require "ground_game/errors/visit_not_allowed"
require "ground_game/errors/invalid_best_canvas_response"

class ErrorSerializer
  def self.serialize(error)
    { errors: [serialize_error(error)] }
  end

  private

    def self.serialize_error(error)
      return serialize_argument_error(error) if error.class == ArgumentError
      return serialize_record_not_found_error(error) if error.class == ActiveRecord::RecordNotFound
      return serialize_visit_not_allowed_error(error) if error.class == GroundGame::VisitNotAllowed
      return serialize_invalid_best_canvas_response_error(error) if error.class == GroundGame::InvalidBestCanvasResponse
    end

    def self.serialize_argument_error(error)
      {
        id: "ARGUMENT_ERROR",
        title: "Argument error",
        detail: error.message,
        status: 422
      }
    end

    def self.serialize_record_not_found_error(error)
      return {
        id: "RECORD_NOT_FOUND",
        title: "Record not found",
        detail: error.message,
        status: 404
      }
    end

    def self.serialize_visit_not_allowed_error(error)
      return {
        id: "VISIT_NOT_ALLOWED",
        title: "Visit not allowed",
        detail: error.message,
        status: 403
      }
    end

    def self.serialize_invalid_best_canvas_response_error(error)
      return {
        id: "INVALID_BEST_CANVAS_RESPONSE",
        title: "Invalid best canvas response",
        detail: error.message,
        status: 422
      }
    end
end
