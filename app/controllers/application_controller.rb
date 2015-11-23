class ApplicationController < ActionController::API
  include Clearance::Controller
  include ActionController::MimeResponds

  before_action :set_default_response_format

  def doorkeeper_unauthorized_render_options(error: nil)
    { json: ErrorSerializer.serialize(error) }
  end

  def signed_in?
    current_user.present?
  end

  def signed_out?
    current_user.nil?
  end

  def current_user
    current_resource_owner
  end

  def record_attributes
    params.require(:data).fetch(:attributes, {})
  end

  def record_relationships
    params.require(:data).fetch(:relationships, {})
  end

  def included_records
    params.fetch(:included, [])
  end

  def render_validation_errors errors
    error_hash = ErrorSerializer.serialize_validation_errors errors
    render json: error_hash, status: error_hash[:errors][0][:status]
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def set_default_response_format
    request.format = :json unless params[:format]
  end
end
