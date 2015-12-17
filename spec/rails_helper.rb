ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'sidekiq/testing'
require 'paperclip/matchers'
require 'clearance/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random

  config.include FactoryGirl::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers

  config.before(:each) do
    allow_any_instance_of(Paperclip::Attachment).to receive(:save).and_return(true)
  end

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  def host
    "https://api.lvh.me:3000"
  end

  def authenticated_get(path, args, token)
    get "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_post(path, args, token)
    post "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_patch(path, args, token)
    patch "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end
end
