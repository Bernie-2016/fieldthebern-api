FactoryGirl.define do
  factory :visit do |f|
    f.total_points 1000
    f.duration_sec 300

    f.user
    f.score

    trait :with_people do
      transient do
        people_count 2
      end

      after(:build) do |visit, evaluator|
        address = create(:address)
        address_update = create(:address_update, address: address, visit: visit)

        people = create_list(:person, evaluator.people_count, address: address)
        people.each do |person|
          create(:person_update, person: person, visit: visit)
        end
      end
    end

    trait :for_address do
      transient do
        address { create(:address) }
        recent? false
      end

      after(:build) do |visit, evaluator|
        minimum_interval_between_visits = ENV["MIN_INTERVAL_BETWEEN_VISITS_HOURS"].to_i
        offset = minimum_interval_between_visits / 2 if evaluator.recent?
        offset = minimum_interval_between_visits * 2 unless evaluator.recent?
        timestamp = DateTime.now - offset.hours
        address_update = create(:address_update, visit: visit, address: evaluator.address, created_at: timestamp)
      end
    end
  end
end
