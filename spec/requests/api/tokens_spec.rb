require 'rails_helper'

describe "Tokens API" do

  describe "POST /oauth/tokens" do

    context "with an email and password" do
      before do
        @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
      end

      it "returns a token when both email and password are valid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'test_password'
        }
        expect(last_response.status).to eq 200
        expect(json.access_token).not_to be_nil
        expect(json.refresh_token).not_to be_nil
      end

      it "fails with 401 when email is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'invalid-email@mail.com',
          password: 'test_password'
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end

      it "fails with 401 when password is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'invalid_password'
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end

      describe "automatic leaderboard update" do
        before do
          @valid_attributes = { grant_type: "password", username: 'existing-user@mail.com', password: 'test_password'}
        end

        it "should update the 'everyone' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/oauth/token", @valid_attributes

            rankings = Ranking.for_everyone(id: 10)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq @user
          end
        end

        it "should update the 'state' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/oauth/token", @valid_attributes

            rankings = Ranking.for_state(id: 10, state_code: "NY")
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq @user
          end
        end

        it "should update the 'friends' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/oauth/token", @valid_attributes

            rankings = Ranking.for_user_in_users_friend_list(user: User.find(10))
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq @user
          end
        end
      end
    end

    context "with a facebook_auth_code" do

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

      context "when facebook user doesn't exist", vcr: { cassette_name: 'requests/api/tokens/facebook_user_not_found' } do
        it "fails with 400" do
          post "#{host}/oauth/token", {
            grant_type: "password",
            username: 'facebook',
            password: 'non-existant-token'
          }

          expect(last_response.status).to eq 400
          expect(json.access_token).to be_nil
        end
      end

      context "when facebook user does exist", vcr: { cassette_name: 'requests/api/tokens/facebook_user_found' } do
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

        context "and there's a user with facebook_id in the database" do
          before do
            @user = create(:user, facebook_id: @facebook_user["id"])
          end

          it "returns a token" do
            post "#{host}/oauth/token", {
              grant_type: "password",
              username: 'facebook',
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 200
            expect(json.access_token).not_to be_nil
            expect(json.refresh_token).not_to be_nil
          end

          it "updates leaderboards" do

            Sidekiq::Testing.inline! do
              post "#{host}/oauth/token", {
                grant_type: "password",
                username: 'facebook',
                password: @facebook_access_token
              }

              rankings = Ranking.for_everyone(id: @user.id)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq @user

              rankings = Ranking.for_state(id: @user.id, state_code: "NY")
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq @user

              rankings = Ranking.for_user_in_users_friend_list(user: @user)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq @user
            end
          end
        end

        context "and there's no user with that facebook_id in the database" do
          it "fails with a 404" do
            post "#{host}/oauth/token", {
              grant_type: "password",
              username: 'facebook',
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 404
            expect(json.access_token).to be_nil
          end
        end
      end
    end
  end
end
