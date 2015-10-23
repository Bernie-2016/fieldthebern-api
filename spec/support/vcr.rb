VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec", "vcr")
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # Uncomment for debugging VCR
  # c.debug_logger = File.open('log/test.log', 'w')

  c.allow_http_connections_when_no_cassette = true

  c.ignore_request do |request|
    URI(request.uri).host == '127.0.0.1'
  end

  c.default_cassette_options = { :serialize_with => :psych }

  ignore_localhost = true

  c.filter_sensitive_data('EASYPOST_API_KEY') { ENV['EASYPOST_API_KEY'] }
end
