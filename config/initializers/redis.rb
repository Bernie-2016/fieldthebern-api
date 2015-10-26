if Rails.env.test?
  $redis = Redis.new
elsif ENV["REDISCLOUD_URL"]
  $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
end
