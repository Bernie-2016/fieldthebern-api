module GroundGame
  module Scenario
    class UpdateUserAttributesFromFacebook
      def initialize(user, facebook_user)
        @user = user
        @facebook_user = facebook_user
      end

      def call
        @user.email = @facebook_user["email"] unless @user.email.present?

        @user.first_name = @facebook_user["first_name"] unless @user.first_name.present?
        @user.last_name = @facebook_user["last_name"] unless @user.last_name.present?

        @user.facebook_id = @facebook_user["id"]
        @user
      end

    end
  end
end
