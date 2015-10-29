require 'raven'

Raven.configure do |config|
  config.environments = %w[ production staging ]
  config.dsn = ENV['SENTRY_DSN']
end
