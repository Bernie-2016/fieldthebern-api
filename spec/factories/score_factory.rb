FactoryGirl.define do
  factory :score do |f|
    f.points_for_updates 20
    f.points_for_knock 5
  end
end
