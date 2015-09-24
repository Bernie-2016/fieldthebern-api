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

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
