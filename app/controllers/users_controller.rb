class UsersController < ApplicationController

  def create
    user = User.new(user_params)
    if user.save
      UpdateProfilePictureWorker.perform_async(user.id)
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

  def update
    if signed_in?
      user = current_user
    else
      render json: {}, status: :unauthorised
    end

    user.update(user_params)

    if user.save
      UpdateProfilePictureWorker.perform_async(user.id)
      render json: user
    else
      render_validation_errors user.errors
    end
  end

  private

  def user_params
    record_attributes.permit(:email, :password, :first_name,
                             :last_name, :state_code, :base_64_photo_data)
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end

end
