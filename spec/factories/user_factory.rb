FactoryGirl.define do
  factory :user do |f|
    f.first_name "John"
    f.last_name "Doe"
    f.password "password"
    f.home_state "NY"
    f.state_code "NY"
    f.lat 1.23456
    f.lng 1.23456
    sequence(:email) { |n| "user_" + n.to_s + "@mail.com" }
  end
end
