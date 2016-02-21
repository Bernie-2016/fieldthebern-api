require "rails_helper"

RSpec.describe GatekeeperMailer, type: :mailer do
  describe "pre_transfer" do
    before do
      @user = FactoryGirl.create(:user)
      @mail = GatekeeperMailer.pre_transfer(@user)
    end

    it "renders the headers" do
      expect(@mail.subject).to eq("Coming soon: New user login system for Field the Bern")
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(["team@fieldthebern.com"])
    end

    it "renders the body" do
      expect(@mail.body.encoded).to match("Coming soon")
    end
  end
end
