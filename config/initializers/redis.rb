if Rails.env.test?
  puts 'env is test, mocking default redis'
  redis = Redis.new
elsif ENV["REDISCLOUD_URL"]
  puts 'we have rediscloud url'
  redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
end

$leaderboard_redis_options = {redis_connection: $redis}
