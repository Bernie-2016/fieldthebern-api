FactoryGirl.define do
  factory :visit do |f|
    f.total_points 1000
    f.duration_sec 300

    association :user, factory: :user
    association :address, factory: :address
  end
end
