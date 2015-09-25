FactoryGirl.define do
  factory :user do |f|
    f.first_name "John"
    f.last_name "Doe"
    f.email "john-doe@mail.com"
    f.password "password"
    f.federal_state "NY"
  end
end
