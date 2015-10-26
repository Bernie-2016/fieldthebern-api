module GroundGame
  module Scenario
    class UpdateUserAttributesFromFacebook
      def initialize(user, facebook_user)
        @user = user
        @facebook_user = facebook_user
      end

      def call
        @user.email = @facebook_user["email"] unless @user.email.present?

        first_name, last_name = first_and_last_name_from_full_name(@facebook_user["name"])
        @user.first_name = first_name unless @user.first_name.present?
        @user.last_name = last_name unless @user.last_name.present?

        @user.facebook_id = @facebook_user["id"]
        @user
      end

      private

        def first_and_last_name_from_full_name(full_name)
          full_name.split(" ", 2)
        end
    end
  end
end
