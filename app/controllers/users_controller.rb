class UsersController < ApplicationController

  def create
    user = User.new(create_params)
    if user.save
      render json: user
    else
      render_validation_errors user.errors
    end
  end

  private

  def create_params
    record_attributes.permit(:email, :password)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end

end
