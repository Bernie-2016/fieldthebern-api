FactoryGirl.define do
  factory :visit do |f|
    f.submitted_street_1 "Test street"
    f.submitted_street_2 ""
    f.submitted_city "Testtown"
    f.submitted_state_code "NY"
    f.submitted_zip_code "12345"

    f.submitted_longitude 1.0
    f.submitted_latitude 1.0

    f.corrected_longitude 1.0
    f.corrected_latitude 1.0

    f.result :not_visited

    f.total_points 1000

    f.duration_sec 300

    association :user, factory: :user
    association :address, factory: :address
  end
end
