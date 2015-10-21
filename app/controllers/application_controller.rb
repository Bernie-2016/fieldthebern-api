class ApplicationController < ActionController::API
  include Clearance::Controller

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
    render json: {errors: errors.to_h}, status: 422
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
