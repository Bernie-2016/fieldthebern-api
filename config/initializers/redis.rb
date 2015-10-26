if ENV["REDISCLOUD_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
elsif Rails.env.test?
  $redis = Redis.new
end
