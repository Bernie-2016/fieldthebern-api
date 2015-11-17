FactoryGirl.define do
  factory :person_update do |f|
    association :person
    association :visit

    f.new_canvas_response :unknown
    f.new_party_affiliation :unknown_affiliation
    f.new_first_name "John"
	f.new_last_name "Doe"
	f.new_address_id 1
	f.new_email "john@doe.com"
	f.new_phone	"555-555-1212"
	f.new_preferred_contact_method "phone"
	f.new_previously_participated_in_caucus_or_primary true
  end
end
