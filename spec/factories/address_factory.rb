FactoryGirl.define do
  factory :address do |f|
    f.street_1 "Test street"
    f.street_2 ""
    f.city "Testtown"
    f.state_code "NY"
    f.zip_code "12345"
    f.longitude 1.0
    f.latitude 1.0

    f.usps_verified_street_1 "Test verified street"
    f.usps_verified_street_2 ""
    f.usps_verified_city "Test verified town"
    f.usps_verified_state "NY"
    f.usps_verified_zip "12345V"

    trait :with_1_person do
      after(:build) do |address, evaluator|
        person = FactoryGirl.build(:person, address: address, canvas_response: :strongly_for)
        address.most_supportive_resident = person
        address.best_canvas_response = person.canvas_response
        address.people = [person]
      end

      after(:create) do |address, evaluator|
        person = FactoryGirl.create(:person, address: address, canvas_response: :strongly_for)
        address.most_supportive_resident = person
        address.best_canvas_response = person.canvas_response
        address.people = [person]
      end
    end
  end
end
