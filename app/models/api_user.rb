class ApiUser < ActiveRecord::Base
  belongs_to :user

  def api_create!(user)
    user_info = {
      "user" => {
        "email" => user.email,
        "encrypted_password" => user.encrypted_password,
        "first_name" => user.first_name,
        "last_name" => user.last_name
      }
    }

    response = RestClient.post("#{ENV["AUTH_API_URL"]}/users", user_info.merge(application_id: ENV['AUTH_API_APPLICATION_ID']))
    response = JSON.load(response.body)

    ApiUser.create!(api_user_id: response["id"], api_access_token: response["access_token"], user_id: user.id)
  end

  def api_save!(user_params)
    user_params = ActionController::Parameters.new({ user: user_params })

    user_info = {
      "user" => user_params.require(:user).permit(:email, :encrypted_password, :first_name, :last_name).to_h
    }

    RestClient.put("#{ENV["AUTH_API_URL"]}/users/me", user_info, access_token: self.api_access_token)
  end
end
