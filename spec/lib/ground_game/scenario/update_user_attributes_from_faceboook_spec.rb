require "rails_helper"
require "ground_game/scenario/update_user_attributes_from_facebook"

module GroundGame
  module Scenario

    describe UpdateUserAttributesFromFacebook do

      describe "#call", vcr: { cassette_name: 'lib/ground_game/scenario/update_user_attributes_from_facebook/default' } do
        before do
          oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
          test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
          @facebook_user = test_users.create(true, "email")
          # Putting our own values into the hash, so we can test for proper data more easily
          @facebook_user["email"] = "test@mail.com"
          @facebook_user["name"] = "John Doe"
          @facebook_user["id"] = "TEST_ID"
        end

        it "updates user email from facebook data if email is not present" do
          user = build(:user, email: nil)
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.email).to eq "test@mail.com"
        end
        it "doesn't alter user email if email is present" do
          user = build(:user, email: "existing@mail.com")
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.email).to eq "existing@mail.com"
        end

        it "updates user first name from facebook data if first name is not present" do
          user = build(:user, first_name: nil)
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.first_name).to eq "John"
        end
        it "doesn't alter first name if first name is present" do
          user = build(:user, first_name: "Jake")
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.first_name).to eq "Jake"
        end

        it "updates user last name from facebook data if last name is not present" do
          user = build(:user, last_name: nil)
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.last_name).to eq "Doe"
        end
        it "doesn't update last name if last name is present" do
          user = build(:user, last_name: "Smith")
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.last_name).to eq "Smith"
        end

        it "updates user facebook id even if id is present" do
          user = build(:user, facebook_id: "EXISTING_ID")
          altered_user = UpdateUserAttributesFromFacebook.new(user, @facebook_user).call
          expect(altered_user.facebook_id).to eq "TEST_ID"
        end
      end

      describe "#first_and_last_name_from_full_name" do
        it "returns first word as first name, remainder as last name" do
          scenario_instance = UpdateUserAttributesFromFacebook.new(nil, nil)
          first_name, last_name = scenario_instance.send(:first_and_last_name_from_full_name, "One Two")
          expect(first_name).to eq "One"
          expect(last_name).to eq "Two"

          first_name, last_name = scenario_instance.send(:first_and_last_name_from_full_name, "One")
          expect(first_name).to eq "One"
          expect(last_name).to eq nil

          first_name, last_name = scenario_instance.send(:first_and_last_name_from_full_name, "One Two Three")
          expect(first_name).to eq "One"
          expect(last_name).to eq "Two Three"
        end
      end
    end
  end
end
