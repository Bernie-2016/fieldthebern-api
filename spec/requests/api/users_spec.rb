require "rails_helper"

describe "Users API" do

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
      }

      expect(last_response.status).to eq 200

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
