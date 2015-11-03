FactoryGirl.define do
  factory :device do |f|
    f.user
    f.platform "Android"
    f.token "12345"
    f.enabled true
  end
end
