require 'rails_helper'

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

  end

end
