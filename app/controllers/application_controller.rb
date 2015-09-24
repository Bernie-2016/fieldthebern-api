class ApplicationController < ActionController::API
  include Clearance::Controller

  def record_attributes
    params.require(:data).fetch(:attributes, {})
  end
end
