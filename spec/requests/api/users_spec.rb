require "rails_helper"

describe "Users API" do

<<<<<<< HEAD
  context "POST /users" do

    it "creates a valid user" do
      post "#{host}/users", {
        data: {
          attributes: {
            email: "joshdotsmith@gmail.com",
            password: "password",
            first_name: "John",
            last_name: "Doe",
            state_code: "NY"
          }
        }
=======
  context 'POST /users' do
    email = 'jane_doe@gmail.com'
    password = 'password'
    first_name = 'Jane'
    last_name = 'Doe'

    it 'creates a valid user without a photo image' do
      post "#{host}/users", {
        data: { attributes: {
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name
        } }
>>>>>>> development
      }
      expect(last_response.status).to eq 200

<<<<<<< HEAD
      expect(json.data.attributes.email).to eq "joshdotsmith@gmail.com"
      expect(json.data.attributes.first_name).to eq "John"
      expect(json.data.attributes.last_name).to eq "Doe"
      expect(json.data.attributes.state_code).to eq "NY"

      user = User.last
      expect(user.persisted?).to be true
      expect(user.email).to eq "joshdotsmith@gmail.com"
      expect(user.first_name).to eq "John"
      expect(user.last_name).to eq "Doe"
      expect(user.state_code).to eq "NY"
=======
      response_data = json.data.attributes
      expect(response_data.email).to eq email
      expect(response_data.first_name).to eq first_name
      expect(response_data.last_name).to eq last_name
      expect(response_data.photo_thumb_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO
      expect(response_data.photo_large_url).to include User::ASSET_HOST_FOR_DEFAULT_PHOTO

      user = User.last
      expect(user.persisted?).to be true
      expect(user.email).to eq email
      expect(user.first_name).to eq first_name
      expect(user.last_name).to eq last_name
    end

    it 'creates a valid user with a photo image' do
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
      expect(user.photo.path).to_not be_nil
      # expect photo saved from create action to be identical to our test photo
      user_photo_file = File.open(user.photo.path, 'r')
      base_64_saved_image = Base64.encode64(open(user_photo_file) { |io| io.read })
      expect(base_64_saved_image).to include base_64_image
>>>>>>> development
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

end
