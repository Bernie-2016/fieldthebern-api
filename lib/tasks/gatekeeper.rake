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

  task notify_users: :environment do
    users = User.all
    counter = 0
    puts "Sending notification mailers for #{users.count} users"

    users.each do |user|
      GatekeeperMailer.pre_transfer(user)
      counter += 1
      puts "Sent notification mailer for #{counter}/#{users.count}"
    end

    puts "Notification mailer email blast completed!"
  end
end
