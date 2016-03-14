ngp_van_enabled = %w(
  NGP_VAN_APPLICATION_NAME
  NGP_VAN_API_KEY
).all? { |key| ENV.key? key }

if ngp_van_enabled
  require 'ngp_van'

  NgpVan.configure do |config|
    config.application_name = ENV['NGP_VAN_APPLICATION_NAME']
    config.api_key = ENV['NGP_VAN_API_KEY']
  end
end
