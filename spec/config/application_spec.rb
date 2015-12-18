require "rails_helper"

describe GroundGame::Application, 'configuration' do
  let(:config) { described_class.config }

  it "has the the environment properly set up to use ssl" do
    # We use the environment to force or not force SSL
    # This spec ensures this behavior is actually happening
    if ENV['FORCE_SSL'] == 'true'
      expect(config.force_ssl).to be true
    else
      expect(config.force_ssl).to be false
    end
  end

  it "changes the 'host' helper value based on environment" do
    if ENV['FORCE_SSL'] == 'true'
      expect(host).to eq "https://api.lvh.me:3000"
    else
      expect(host).to eq "http://api.lvh.me:3000"
    end
  end
end
