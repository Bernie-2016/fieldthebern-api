FactoryGirl.define do
  factory :address do |f|
    f.street_1 "Test street"
    f.street_2 ""
    f.city "Testtown"
    f.state_code "NY"
    f.zip_code "12345"
    f.longitude 1.0
    f.latitude 1.0

    after(:build) do |address, evaluator|
      address.most_supportive_resident = FactoryGirl.build(:person, address: address)
    end

    after(:create) do |address, evaluator|
      address.most_supportive_resident = FactoryGirl.build(:person, address: address)
    end
  end
end
