require 'faker'

10.times do
  u = User.new
  u.first_name = Faker::Name.first_name
  u.last_name = Faker::Name.last_name
  u.password = Faker::Internet.password(8)
  u.email = Faker::Internet.email
  u.save
end
