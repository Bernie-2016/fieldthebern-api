FactoryGirl.define do
  factory :person_update do |f|
    f.person
    f.visit

    f.new_canvas_response :unknown
    f.new_party_affiliation :unknown_affiliation
  end
end
