FactoryGirl.define do
  factory :ranking do |f|
    f.score 20
    f.rank 1
    f.member nil
    f.member_data nil
  end
end
