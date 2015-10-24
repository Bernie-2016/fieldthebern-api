class UsersController < ApplicationController

  def create
    user = User.new(user_params)
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

  def edit_me
    user = current_user
    user.update(user_params)
    
    if user.save
      if user_params[:base_64_photo_data].present?
        UpdateProfilePictureWorker.perform_async(user.id)
      end

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
