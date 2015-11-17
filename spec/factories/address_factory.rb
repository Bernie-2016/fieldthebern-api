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
        person = FactoryGirl.build(:person, address: address, canvass_response: :strongly_for)
        address.most_supportive_resident = person
        address.best_canvass_response = person.canvass_response
        address.people = [person]
      end

      after(:create) do |address, evaluator|
        person = FactoryGirl.create(:person, address: address, canvass_response: :strongly_for)
        address.most_supportive_resident = person
        address.best_canvass_response = person.canvass_response
        address.people = [person]
      end
    end

    transient do
      recently_visited? false
    end

    after(:build) do |address, evaluator|
      unless evaluator.visited_at
        minimum_interval_between_visits = (ENV["MIN_INTERVAL_BETWEEN_VISITS_HOURS"] || 1).to_i
        offset = minimum_interval_between_visits / 2 if evaluator.recently_visited?
        offset = minimum_interval_between_visits * 2 unless evaluator.recently_visited?
        timestamp = DateTime.now - offset.hours
        address.visited_at = timestamp
      end
    end
  end
end
