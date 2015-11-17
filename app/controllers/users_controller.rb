
class UsersController < ApplicationController
  before_filter :require_login, only: [:update, :me]

  def create
    if creating_with_facebook?
      create_user_from_facebook_and_render_json
    else
      create_user_with_email_and_render_json
    end
  end

  def lookup
    user = User.where(user_params)
    render json: user
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def me
    render json: current_user
  end

  def update
    user = current_user

    user.update(user_params)

    if user.save
      update_leaderboards_and_render_json(user)
    else
      render_validation_errors(user.errors)
    end
  end

  private

  def create_user_from_facebook_and_render_json
    user = User.where("facebook_id = ? OR email = ?", user_params[:facebook_id], user_params[:email]).first_or_create

    user.update(user_params)

    if user.save
      InitializeNewFacebookUserWorker.perform_async(user.id)
      if photo_param?
        UpdateProfilePictureWorker.perform_async(user.id)
      else
        AddFacebookProfilePicture.perform_async(user.id)
      end
      UpdateUsersLeaderboardsWorker.perform_async(user.id)

      render json: user
    else
      render_validation_errors(user.errors)
    end
  end

  def create_user_with_email_and_render_json
    user = User.new(user_params)

    if user.save
      update_leaderboards_and_render_json(user)
    else
      render_validation_errors(user.errors)
    end
  end

  def update_leaderboards_and_render_json(user)
    UpdateProfilePictureWorker.perform_async(user.id) if photo_param?
    UpdateUsersLeaderboardsWorker.perform_async(user.id)
    render json: user
  end

  def user_params
    record_attributes.permit(:email, :password, :first_name,
                             :last_name, :state_code, :base_64_photo_data,
                             :lat, :lng, :facebook_id, :facebook_access_token)
  end

  def creating_with_facebook?
    user_params[:facebook_id].present? && user_params[:facebook_access_token].present?
  end

  def photo_param?
    user_params[:base_64_photo_data].present?
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end

end
