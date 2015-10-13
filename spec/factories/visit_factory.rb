FactoryGirl.define do
  factory :visit do |f|
    f.total_points 1000
    f.duration_sec 300

    association :user
    association :address, :with_1_person
  end
end
