require 'rails_helper'

describe "Ping API" do

  it 'gets a pong when pinging' do
    get "#{host}/ping"

    expect(last_response.status).to eq 200
    expect(json.ping).to eq "pong"
  end

end
