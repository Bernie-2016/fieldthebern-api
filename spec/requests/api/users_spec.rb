require "rails_helper"

describe "Users API" do

  context 'POST /users' do
    email = 'jane_doe@gmail.com'
    password = 'password'
    first_name = 'Jane'
    last_name = 'Doe'
    state_code = 'NY'
    lat = 1.23456
    lng = -1.23456

    context "with Facebook" do

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
        InitializeNewFacebookUserWorker.drain
        AddFacebookProfilePicture.drain
      end

      context "when the user does not already exist" do

        it "creates a valid user without a photo image", sidekiq: :fake, vcr: { cassette_name: 'requests/api/users/with facebook/when the user does not already exist/creates a user without a photo' } do
          post "#{host}/users", {
            data: {
              attributes: {
                facebook_id: @facebook_user["id"],
                facebook_access_token: @facebook_access_token,
                email: email,
                password: password,
                first_name: first_name,
                last_name: last_name,
                state_code: state_code,
                lat: lat,
                lng: lng
              }
            }
          }
          expect(last_response.status).to eq 200

          response_data = json.data.attributes
          expect(response_data.email).to eq email
          expect(response_data.first_name).to eq first_name
          expect(response_data.last_name).to eq last_name
          expect(response_data.state_code).to eq state_code
          expect(response_data.lat).to eq lat.to_s
          expect(response_data.lng).to eq lng.to_s
          expect(response_data.photo_thumb_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO
          expect(response_data.photo_large_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO

          user = User.last
          expect(user.persisted?).to be true
          expect(user.email).to eq email
          expect(user.first_name).to eq first_name
          expect(user.last_name).to eq last_name
          expect(user.state_code).to eq state_code
          expect(user.lat).to eq lat
          expect(user.lng).to eq lng
          expect(user.facebook_id).to eq @facebook_user["id"]
          expect(user.facebook_access_token).to eq @facebook_access_token

          expect(InitializeNewFacebookUserWorker.jobs.size).to eq 1
          expect(AddFacebookProfilePicture.jobs.size).to eq 1
          expect(UpdateProfilePictureWorker.jobs.size).to eq 0
        end
      end

      context "when the user already exists" do

        before do
          create(:user, email: @facebook_user["email"])
        end

        it 'updates the user with a user uploaded image', sidekiq: :fake, vcr: { cassette_name: 'requests/api/users/with facebook/when the user already exists/updates the user with a user uploaded image' } do
          Sidekiq::Testing.inline! do
            file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
            base_64_image = Base64.encode64(open(file) { |io| io.read })

            post "#{host}/users", {
              data: {
                attributes: {
                  facebook_id: @facebook_user["id"],
                  facebook_access_token: @facebook_access_token,
                  email: email,
                  password: password,
                  first_name: first_name,
                  last_name: last_name,
                  state_code: state_code,
                  base_64_photo_data: base_64_image,
                  lat: lat,
                  lng: lng
                }
              }
            }

            expect(last_response.status).to eq 200

            user = User.last
            expect(user.base_64_photo_data).to be_nil
            expect(user.photo.path).to_not be_nil
            # expect photo saved from create action to be identical to our test photo
            user_photo_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
            base_64_saved_image = Base64.encode64(open(user_photo_file) { |io| io.read })
            expect(base_64_saved_image).to include base_64_image
          end
        end

        it "updates the user without a photo image", sidekiq: :fake, vcr: { cassette_name: 'requests/api/users/with facebook/when the user already exists/updates the user without a photo' } do
          post "#{host}/users", {
            data: {
              attributes: {
                facebook_id: @facebook_user["id"],
                facebook_access_token: @facebook_access_token,
                email: email,
                password: password,
                first_name: first_name,
                last_name: last_name,
                state_code: state_code,
                lat: lat,
                lng: lng
              }
            }
          }
          expect(last_response.status).to eq 200

          response_data = json.data.attributes
          expect(response_data.email).to eq email
          expect(response_data.first_name).to eq first_name
          expect(response_data.last_name).to eq last_name
          expect(response_data.state_code).to eq state_code
          expect(response_data.lat).to eq lat.to_s
          expect(response_data.lng).to eq lng.to_s
          expect(response_data.photo_thumb_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO
          expect(response_data.photo_large_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO

          user = User.last
          expect(user.persisted?).to be true
          expect(user.email).to eq email
          expect(user.first_name).to eq first_name
          expect(user.last_name).to eq last_name
          expect(user.state_code).to eq state_code
          expect(user.lat).to eq lat
          expect(user.lng).to eq lng
          expect(user.facebook_id).to eq @facebook_user["id"]
          expect(user.facebook_access_token).to eq @facebook_access_token

          expect(InitializeNewFacebookUserWorker.jobs.size).to eq 1
          expect(AddFacebookProfilePicture.jobs.size).to eq 1
          expect(UpdateProfilePictureWorker.jobs.size).to eq 0
        end
      end

      describe "automatic leaderboard update" do

        context "created with a photo", sidekiq: :fake, vcr: { cassette_name: 'requests/api/users/with facebook/automatic leaderboard update/created with a photo' }  do

          before do
            Sidekiq::Testing.inline! do
              file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
              base_64_image = Base64.encode64(open(file) { |io| io.read })

              @user_attributes = {
                data: {
                  attributes: {
                    facebook_id: @facebook_user["id"],
                    facebook_access_token: @facebook_access_token,
                    email: email,
                    password: password,
                    first_name: first_name,
                    last_name: last_name,
                    state_code: state_code,
                    base_64_photo_data: base_64_image,
                    lat: lat,
                    lng: lng
                  }
                }
              }
            end
          end

          it "should update the 'everyone' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_everyone(id: User.last.id)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end

          it "should update the 'state' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end

          it "should update the 'friends' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_user_in_users_friend_list(user: User.last)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end
        end

        context "created without a photo", sidekiq: :fake, vcr: { cassette_name: 'requests/api/users/with facebook/automatic leaderboard update/created without a photo' }  do

          before do
            Sidekiq::Testing.inline! do

              @user_attributes = {
                data: {
                  attributes: {
                    facebook_id: @facebook_user["id"],
                    facebook_access_token: @facebook_access_token,
                    email: email,
                    password: password,
                    first_name: first_name,
                    last_name: last_name,
                    state_code: state_code,
                    lat: lat,
                    lng: lng
                  }
                }
              }
            end
          end

          it "should update the 'everyone' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_everyone(id: User.last.id)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end

          it "should update the 'state' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end

          it "should update the 'friends' leaderboard" do
            Sidekiq::Testing.inline! do
              post "#{host}/users", @user_attributes

              rankings = Ranking.for_user_in_users_friend_list(user: User.last)
              expect(rankings.length).to eq 1
              expect(rankings.first.user).to eq User.last
            end
          end
        end
      end
    end

    context "without Facebook" do

      it 'creates a valid user without a photo image' do
        post "#{host}/users", {
          data: { attributes: {
            email: email,
            password: password,
            first_name: first_name,
            last_name: last_name,
            state_code: state_code,
            lat: lat,
            lng: lng
          } }
        }
        expect(last_response.status).to eq 200

        response_data = json.data.attributes
        expect(response_data.email).to eq email
        expect(response_data.first_name).to eq first_name
        expect(response_data.last_name).to eq last_name
        expect(response_data.state_code).to eq state_code
        expect(response_data.lat).to eq lat.to_s
        expect(response_data.lng).to eq lng.to_s
        expect(response_data.photo_thumb_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO
        expect(response_data.photo_large_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO

        user = User.last
        expect(user.persisted?).to be true
        expect(user.email).to eq email
        expect(user.first_name).to eq first_name
        expect(user.last_name).to eq last_name
        expect(user.state_code).to eq state_code
        expect(user.lat).to eq lat
        expect(user.lng).to eq lng

        expect(InitializeNewFacebookUserWorker.jobs.size).to eq 0
        expect(AddFacebookProfilePicture.jobs.size).to eq 0
        expect(UpdateProfilePictureWorker.jobs.size).to eq 0
      end

      it 'creates a valid user with a photo image' do
        Sidekiq::Testing.inline! do
          file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base_64_image = Base64.encode64(open(file) { |io| io.read })

          post "#{host}/users", {
            data: { attributes: {
              email: email,
              password: password,
              first_name: first_name,
              last_name: last_name,
              base_64_photo_data: base_64_image,
              lat: lat,
              lng: lng
            } }
          }
          expect(last_response.status).to eq 200
          user = User.last
          expect(user.base_64_photo_data).to be_nil
          expect(user.photo.path).to_not be_nil
          # expect photo saved from create action to be identical to our test photo
          user_photo_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base_64_saved_image = Base64.encode64(open(user_photo_file) { |io| io.read })
          expect(base_64_saved_image).to include base_64_image
        end
      end

      context "with invalid data" do

        it "fails on a blank password" do
          post "#{host}/users", {
            data: { attributes: {
              email: "joshdotsmith@gmail.com",
              password: "",
            } }
          }

          expect(last_response.status).to eq 422

          expect(json.errors.password).to eq "can't be blank"
        end
      end

      context "when user accounts are taken" do

        before do
          create(:user, email: "joshdotsmith@gmail.com", password: "password")
        end

        it "fails when the email is taken" do
          post "#{host}/users", {
            data: { attributes: {
              email: "joshdotsmith@gmail.com",
              password: "password"
            } }
          }

          expect(last_response.status).to eq 422

          expect(json.errors.email).to eq "has already been taken"
        end
      end

      context "when the user is being created with a photo" do
        before do
          file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base_64_image = Base64.encode64(open(file) { |io| io.read })
          @user_attributes = {
            data: {
              attributes: {
                email: email,
                password: password,
                first_name: first_name,
                last_name: last_name,
                state_code: "NY",
                base_64_photo_data: base_64_image
              }
            }
          }
        end

        it "should update the 'everyone' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_everyone(id: User.last.id)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'state' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'friends' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_user_in_users_friend_list(user: User.last)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end
      end

      context "when the user is being created without a photo" do
        before do
          @user_attributes = {
            data: {
              attributes: {
                email: email,
                password: password,
                first_name: first_name,
                last_name: last_name,
                state_code: "NY"
              }
            }
          }
        end

        it "should update the 'everyone' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_everyone(id: User.last.id)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'state' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'friends' leaderboard" do
          Sidekiq::Testing.inline! do
            post "#{host}/users", @user_attributes

            rankings = Ranking.for_user_in_users_friend_list(user: User.last)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end
      end
    end
  end

  context 'POST /users/me' do
    before do
        @user = create(:user, id: 11, email: "test-user@mail.com", password: "password", state_code: "NY")
    end

    let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

    it 'returns unauthorized when you try to edit any user and are not logged in' do
      create(:user)

      patch "#{host}/users/me", {
        data: { attributes: {
          email: 'new@new.com'
        } }
      }

      expect(last_response.status).to eq 401
      expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
    end

    it 'successfully updates yourself when you are logged in' do

      authenticated_patch "users/me", {
        data: { attributes: {
          email: 'new@new.com'
        } }
      }, token

      expect(last_response.status).to eq 200
      @user.reload
      expect(@user.email).to eq 'new@new.com'
    end

    it 'can update a photo' do
      Sidekiq::Testing.inline! do
        file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_image = Base64.encode64(open(file) { |io| io.read })

        authenticated_patch "users/me", {
          data: { attributes: { base_64_photo_data: base_64_image} }
        }, token
        expect(last_response.status).to eq 200
        @user.reload
        expect(@user.base_64_photo_data).to be_nil
        expect(@user.photo.path).to_not be_nil
        expect(@user.photo.url(:original)).to include "cloudfront"
        expect(@user.photo.url(:original)).to include "users/#{@user.id}/original"
      end
    end

    describe "automatic leaderboard update" do

      context "when the user is having their photo updated" do
        before do
          file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base_64_image = Base64.encode64(open(file) { |io| io.read })
          @user_attributes = { data: { attributes: { email: "new@mail.com", base_64_photo_data: base_64_image } } }
        end

        it "should update the 'everyone' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_everyone(id: User.last.id)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'state' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'friends' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_user_in_users_friend_list(user: User.last)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end
      end

      context "when the user is not having their photo updated" do
        before do
          @token = token  # need to evaluate token ahead of time
          @user_attributes = { data: { attributes: { email: "new@mail.com" } } }
        end

        it "should update the 'everyone' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_everyone(id: User.last.id)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'state' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_state(id: User.last.id, state_code: "NY")
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end

        it "should update the 'friends' leaderboard" do
          Sidekiq::Testing.inline! do
            authenticated_patch "users/me", @user_attributes, token

            rankings = Ranking.for_user_in_users_friend_list(user: User.last)
            expect(rankings.length).to eq 1
            expect(rankings.first.user).to eq User.last
          end
        end
      end
    end
  end

  context 'GET /users/me' do
    email = 'test-user@mail.com'
    password = 'password'
    state_code = "NY"

    before(:each) do
        @user = create(:user, id: 11, email: email, password: password, state_code: state_code)
    end

    let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

    it 'should return unauthorized if not logged in' do
      get "#{host}/users/me"
      expect(last_response.status).to eq 401
      expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
    end

    it 'should return the correct data if logged in' do
      authenticated_get 'users/me', {}, token
      expect(last_response.status).to eq 200

      response_data = json.data.attributes
      expect(response_data.email).to eq email
      expect(response_data.state_code).to eq state_code
    end
  end

  context 'GET users/lookup' do
    before(:each) do
        @user = create(:user, email: "josh@coderly.com", password: "password", facebook_id: 12345)
    end

    let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

    it 'should return no users if they do not exist' do
      get "#{host}/users/lookup", { data: { attributes: { facebook_id: "678910" } } }
      expect(last_response.status).to eq 200

      response_data = json.data
      expect(response_data.count).to eq 0
    end

    it 'should return users if they do exist' do
      get "#{host}/users/lookup", { data: { attributes: { facebook_id: "12345" } } }
      expect(last_response.status).to eq 200

      response_data = json.data
      expect(response_data.count).to eq 1
    end
  end

  context 'GET /users/:id' do
    email = 'test-user@mail.com'
    password = 'password'
    state_code = "NY"

    before(:each) do
        @user = create(:user, id: 11, email: email, password: password, state_code: state_code)
    end

    it 'should retrieve a specific user' do
      get "#{host}/users/#{@user.id}"

      expect(last_response.status).to eq 200

      response_data = json.data.attributes
      expect(response_data.email).to eq email
      expect(response_data.state_code).to eq state_code
    end
  end
end
