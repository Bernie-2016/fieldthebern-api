require "ground_game/errors/visit_not_allowed"
require "ground_game/errors/invalid_best_canvass_response"
require "ground_game/errors/address_unmatched"
require "ground_game/easypost_error_adapter"

class ErrorSerializer
  def self.serialize(error)
    error_hash = send(serializer_mapping[error.class], error)

    { errors: Array.wrap(error_hash) }
  end

  private
    def self.serializer_mapping
      {
        ArgumentError                                 => :serialize_argument_error,
        ActiveRecord::RecordNotFound                  => :serialize_record_not_found_error,
        GroundGame::VisitNotAllowed                   => :serialize_visit_not_allowed_error,
        GroundGame::InvalidBestCanvassResponse        => :serialize_invalid_best_canvass_response_error,
        EasyPost::Error                               => :serialize_easypost_error,
        GroundGame::AddressUnmatched                  => :serialize_address_unmatched_error,
        Koala::Facebook::AuthenticationError          => :serialize_facebook_authentication_error,
        Doorkeeper::OAuth::InvalidTokenResponse       => :serialize_doorkeeper_oauth_invalid_token_response,
        Doorkeeper::OAuth::ErrorResponse              => :serialize_doorkeeper_oauth_error_response,
        ActiveModel::Errors                           => :serialize_validation_errors,
      }
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

    def self.serialize_invalid_best_canvass_response_error(error)
      return {
        id: "INVALID_BEST_CANVASS_RESPONSE",
        title: "Invalid best canvass response",
        detail: error.message,
        status: 422
      }
    end

    def self.serialize_easypost_error(error)
      adapted_error = GroundGame::EasyPostErrorAdapter.new(error)
      return {
        id: adapted_error.id,
        title: adapted_error.title,
        detail: adapted_error.detail,
        status: adapted_error.status
      }
    end

    def self.serialize_address_unmatched_error(error)
      return {
        id: "ADDRESS_UNMATCHED",
        title: "Address unmatched",
        detail: error.message,
        status: 404
      }
    end

    def self.serialize_facebook_authentication_error(error)
      return {
        id: "FACEBOOK_AUTHENTICATION_ERROR",
        title: "Facebook authentication error",
        detail: error.fb_error_message,
        status: error.http_status
      }
    end

    def self.serialize_doorkeeper_oauth_invalid_token_response(error)
      return {
        id: "NOT_AUTHORIZED",
        title: "Not authorized",
        detail: error.description,
        status: 401
      }
    end

    def self.serialize_doorkeeper_oauth_error_response(error)
      return {
        id: "INVALID_GRANT",
        title: "Invalid grant",
        detail: error.description,
        status: 401
      }
    end

    def self.serialize_validation_errors(errors)
      errors.to_hash(true).map do |k, v|
        v.map do |msg|
          { id: "VALIDATION_ERROR", title: "#{k.capitalize} error", detail: msg, status: 422 }
        end
      end.flatten
    end
end
