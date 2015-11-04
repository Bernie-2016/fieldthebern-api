FactoryGirl.define do
  factory :device do |f|
    f.association :user

    f.platform "Android"
    f.token "12345"
    f.enabled true
  end
end
