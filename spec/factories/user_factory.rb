FactoryGirl.define do
  factory :user do |f|
    f.first_name "John"
    f.last_name "Doe"
    f.password "password"

    sequence(:email) { |n| "user_" + n.to_s + "@mail.com" }
  end
end
