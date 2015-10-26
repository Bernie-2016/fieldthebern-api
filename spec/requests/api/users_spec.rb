require "rails_helper"

describe "Users API" do

  context 'POST /users' do
    email = 'jane_doe@gmail.com'
    password = 'password'
    first_name = 'Jane'
    last_name = 'Doe'
    state_code = 'NY'

    it 'creates a valid user without a photo image' do
      post "#{host}/users", {
        data: { attributes: {
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name,
          state_code: state_code
        } }
      }
      expect(last_response.status).to eq 200

      response_data = json.data.attributes
      expect(response_data.email).to eq email
      expect(response_data.first_name).to eq first_name
      expect(response_data.last_name).to eq last_name
      expect(response_data.state_code).to eq state_code
      expect(response_data.photo_thumb_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO
      expect(response_data.photo_large_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO

      user = User.last
      expect(user.persisted?).to be true
      expect(user.email).to eq email
      expect(user.first_name).to eq first_name
      expect(user.last_name).to eq last_name
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
            base_64_photo_data: base_64_image
          } }
        }
        expect(last_response.status).to eq 200
        user = User.last
        expect(user.base_64_photo_data).to be_nil
        expect(user.photo.path).to_not be_nil
        # expect photo saved from create action to be identical to our test photo
        user_photo_file = File.open(user.photo.path, 'r')
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

  end

  context 'PATCH/user' do
    before do
        @user = create(:user, id: 11, email: "test-user@mail.com", password: "password", state_code: "NY")
    end

    let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

    it 'returns unauthorized when you try to edit any user and are not logged in' do
      user = create(:user)

      post "#{host}/users/me", {
        data: { attributes: {
          email: 'new@new.com'
        } }
      }

      expect(last_response.status).to eq 401
    end

    it 'successfully updates yourself when you are logged in' do

      authenticated_post "users/me", {
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

        authenticated_post "users/me", {
          data: { attributes: { base_64_photo_data: base_64_image} }
        }, token
        expect(last_response.status).to eq 200
        @user.reload
        expect(@user.base_64_photo_data).to be_nil
        expect(@user.photo.path).to_not be_nil
        # expect photo saved from create action to be identical to our test photo
        user_photo_file = File.open(@user.photo.path, 'r')
        base_64_saved_image = Base64.encode64(open(user_photo_file) { |io| io.read })
        expect(base_64_saved_image).to include base_64_image
      end
    end
  end

  context 'GET users/me' do
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
    end

    it 'should return the correct data if logged in' do
      authenticated_get 'users/me', {}, token
      expect(last_response.status).to eq 200

      response_data = json.data.attributes
      expect(response_data.email).to eq email
      expect(response_data.state_code).to eq state_code
    end
  end

  context 'users/SHOW' do
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
