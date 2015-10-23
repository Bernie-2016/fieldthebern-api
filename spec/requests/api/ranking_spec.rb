require "rails_helper"

describe "Rankings API" do
  describe "GET /rankings" do
    it "requires authentication" do
      get "#{host}/rankings"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do

      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, email: "test-user@mail.com", password: "password")
      end

      it "can return the rankings of 'everyone'"
      it "can return the rankings of 'state'"
      it "can return the rankings of 'friends'"
    end
  end
end
