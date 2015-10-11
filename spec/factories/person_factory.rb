FactoryGirl.define do
  factory :person do |f|
    f.first_name "John"
    f.last_name "Doe"
    f.party_affiliation :unknown
    f.canvas_response :unknown

    association :address, factory: :address
  end
end
