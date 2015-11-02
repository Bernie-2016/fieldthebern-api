require 'rails_helper'

describe "Devices API" do

  let(:token) { authenticate(email: "test-user@mail.com", password: "password") }
  before do
    create(:user, email: "test-user@mail.com", password: "password")
  end


  it "should register a devise for a user" do
    authenticated_get 'users/me', {}, token

    user_id = json.data.id

    authenticated_post "devices", {
      data: {
        attributes: {
          token: "123456",
          enabled: true,
          platform: "Android"
        }
      }
    }, token

    expect(json.id).not_to be_blank
    expect(json.token).to eq "123456"
    expect(json.platform).to eq "Android"
    expect(json).to be_enabled
    expect(json.user_id.to_s).to eq user_id.to_s
  end

end
