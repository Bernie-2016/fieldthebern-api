class UsersController < ApplicationController

  def create
    user = User.new(create_params)
    if user.save
      render json: user
    else
      render_validation_errors user.errors
    end
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def me
    render json: current_user
  end

  private

  def create_params
    record_attributes.permit(:email, :password, :first_name, :last_name, :state_code)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end

end
