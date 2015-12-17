require "rails_helper"

describe GroundGame::Application, 'configuration' do
  let(:config) { described_class.config }

  it "has the the environment properly set up to use ssl" do
    # I could not find a way to load configuration for another environment.
    # However, if production is properly set up, this test should pass on staging
    # If it doesn't, it means we did not set up config to use ssl on production
    expect(config.force_ssl).to be true
  end
end
