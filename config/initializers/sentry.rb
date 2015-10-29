require 'raven'

Raven.configure do |config|
  config.environments = ['staging', 'production']
  config.dsn = ENV['SENTRY_DSN']
end
