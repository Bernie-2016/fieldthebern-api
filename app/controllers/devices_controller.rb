class DevicesController < ApplicationController
  def create
    device = Device.where(
      token: device_params[:token],
      user_id: device_params[:user_id]
    ).first_or_create.tap do |d|
      d.enabled = device_params[:enabled]
      d.platform = device_params[:platform]
    end

    if device.save
      render json: device
    else
      render_validation_errors(device.errors)
    end
  end

  private

  def device_params
    record_attributes.permit(
      :token, :enabled, :platform
    ).merge(user_id: current_user.id)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end
end
