namespace :gatekeeper do
  task migrate_users: :environment do
    users = User.all
    counter = 0
    puts "Creating API integration for #{users.count} users"

    users.each do |user|
      user.api_user = ApiUser.new.api_create!(user)
      counter += 1
      puts "Finished API integration for #{counter}/#{users.count}"
    end

    puts "API integration completed!"
  end
end
