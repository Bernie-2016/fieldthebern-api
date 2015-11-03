FactoryGirl.define do
  factory :person_update do |f|
    association :person
    association :visit

    f.new_canvas_response :unknown
    f.new_party_affiliation :unknown_affiliation
  end
end
