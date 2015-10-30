FactoryGirl.define do
  factory :visit do |f|
    f.total_points 1000
    f.duration_sec 300

    f.user
    f.score

    after(:build) do |visit, evaluator|
      address = create(:address)
      address_update = create(:address_update, address: address, visit: visit)
    end

    trait :with_people do
      transient do
        people_count 2
      end

      after(:build) do |visit, evaluator|
        if evaluator.people_count > 0
          people = create_list(:person, evaluator.people_count, address: visit.address)
          people.each do |person|
            create(:person_update, person: person, visit: visit)
          end
        end
      end
    end
  end
end
