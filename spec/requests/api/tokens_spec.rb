require 'rails_helper'
require 'ground_game/scenario/update_user_attributes_from_facebook'

describe "Tokens API" do

  describe "POST /oauth/tokens" do

    context "with an email and password" do
      it "returns a token when both email and password are valid" do
        create(:user, email: 'existing-user@mail.com', password: 'test_password')
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'test_password'
        }
        expect(last_response.status).to eq 200
        expect(json.access_token).not_to be nil
      end

      it "fails with 401 when email is invalid" do
        create(:user, email: 'existing-user@mail.com', password: 'test_password')
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'invalid-email@mail.com',
          password: 'test_password'
        }

        expect(last_response.status).to eq 401
        expect(json.error).to eq 'invalid_grant'
      end

      it "fails with 401 when password is invalid" do
        create(:user, email: 'existing-user@mail.com', password: 'test_password')
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'invalid_password'
        }

        expect(last_response.status).to eq 401
        expect(json.error).to eq 'invalid_grant'
      end

    end

    context "with a facebook_auth_code", sidekiq: :fake, vcr: { cassette_name: 'requests/api/tokens/creates a user' } do

      before do
        oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
        test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
        @facebook_user = test_users.create(true, "email,user_friends")
        short_lived_token = @facebook_user["access_token"]
        long_lived_token_info = oauth.exchange_access_token_info(short_lived_token)
        facebook_auth_code = oauth.generate_client_code(long_lived_token_info["access_token"])
        access_token_info = oauth.get_access_token_info(facebook_auth_code)
        @facebook_access_token = access_token_info["access_token"] || JSON.parse(access_token_info.keys[0])["access_token"]
      end

      after do
        AddFacebookFriendsWorker.drain
      end

      context "when the user does not already exist" do

        it 'creates a user from Facebook and returns a token' do

          expect_any_instance_of(GroundGame::Scenario::UpdateUserAttributesFromFacebook).to receive(:call).and_call_original

          post "#{host}/oauth/token", {
            username: "facebook",
            password: @facebook_access_token
          }
          expect(last_response.status).to eq 200
          expect(json.access_token).to_not be_nil
          expect(json.user_id).to_not be_nil
          expect(json.expires_in).to eq 7200
          expect(json.token_type).to eq "bearer"

          expect(AddFacebookFriendsWorker.jobs.size).to eq 1
        end

        it "fills in missing information from facebook data" do
         expect_any_instance_of(Koala::Facebook::API).to receive(:get_object)
            .and_return("name" => "Charlie Smith", "email" => "new@mail.com", "id" => "TEST")

          post "#{host}/oauth/token", {
            username: "facebook",
            password: @facebook_access_token
          }

          user = User.last
          expect(user.email).to eq "new@mail.com"
          expect(user.first_name).to eq "Charlie"
          expect(user.last_name).to eq "Smith"
          expect(user.facebook_id).to eq "TEST"
        end

      end

      context "when the user already exists" do

        context "with just the same email" do
          it 'updates the user from Facebook and returns a token' do
            user = create(:user, email: @facebook_user["email"], facebook_id: nil)

            expect_any_instance_of(GroundGame::Scenario::UpdateUserAttributesFromFacebook).to receive(:call).and_call_original

            post "#{host}/oauth/token", {
              username: "facebook",
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 200

            expect(json.access_token).to_not be_nil
            expect(json.user_id).to eq user.id.to_s
            expect(json.expires_in).to eq 7200
            expect(json.token_type).to eq "bearer"
          end
        end

        context "with just the same facebook_id" do
          it 'updates the user from Facebook and returns a token', vcr: { cassette_name: 'requests/api/tokens/creates a user' } do
            user = create(:user, email: "different@email.com", facebook_id: @facebook_user["id"])

            expect_any_instance_of(GroundGame::Scenario::UpdateUserAttributesFromFacebook).to receive(:call).and_call_original

            post "#{host}/oauth/token", {
              username: "facebook",
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 200

            expect(json.access_token).to_not be_nil
            expect(json.user_id).to eq user.id.to_s
            expect(json.expires_in).to eq 7200
            expect(json.token_type).to eq "bearer"
          end
        end

        it "fills in missing information from facebook data" do
          user = create(:user, email: "existing@mail.com", facebook_id: "TEST", first_name: nil, last_name: nil)
          expect_any_instance_of(Koala::Facebook::API).to receive(:get_object)
            .and_return("name" => "Charlie Smith", "email" => "new@mail.com", "id" => "TEST")

          post "#{host}/oauth/token", {
            username: "facebook",
            password: @facebook_access_token
          }

          user = User.last
          expect(user.email).to eq "existing@mail.com"
          expect(user.first_name).to eq "Charlie"
          expect(user.last_name).to eq "Smith"
          expect(user.facebook_id).to eq "TEST"
        end

      end

    end

  end

end
