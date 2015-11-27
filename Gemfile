source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.4'

gem 'rails-api'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

gem 'rack-cors', :require => 'rack/cors'

gem 'doorkeeper'
gem 'clearance'

gem 'spring', :group => :development

gem 'hashie'

gem 'pg'

gem 'koala'

gem 'sidekiq'

gem 'geokit-rails'

gem 'easypost'

gem 'leaderboard'

gem 'parse-ruby-client'

gem 'phonelib'
gem 'email_validator'

# paperclip master currently doesn't work with new version of AWS SDK
gem 'paperclip', :git=> 'https://github.com/thoughtbot/paperclip', :ref => '523bd46c768226893f23889079a7aa9c73b57d68'

gem 'aws-sdk'

gem 'unicorn'

gem "sentry-raven"

gem 'newrelic_rpm'

gem 'rack-cors', require: 'rack/cors'

group :development, :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'

  gem 'pry-rails'
  gem 'pry'
  gem 'pry-nav'

  gem 'bullet'
end

group :development do
  gem 'faker'
end

group :test do
  gem 'factory_girl_rails'
  gem 'oauth2'
  gem 'vcr'
  gem 'webmock'
  gem 'fakeredis', :require => "fakeredis/rspec"
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'rspec-sidekiq'
end
