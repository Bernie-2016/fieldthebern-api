FactoryGirl.define do
  factory :user do |f|
    f.first_name "John"
    f.last_name "Doe"
    f.password "password"
    f.state_code "NY"
    f.lat 1.23456
    f.lng 1.23456
    sequence(:email) { |n| "user_" + n.to_s + "@mail.com" }

    trait :with_a_photo do
      after(:build) do |user, evaluator|
        file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_image = Base64.encode64(open(file) { |io| io.read })
        user.base_64_photo_data = base_64_image
        user.decode_image_data
      end
    end

    trait :with_s3_photo do
      after(:build) do |user, evaluator|
        user.photo_file_name = 'user.jpg'
        user.photo_content_type = 'image/jpeg'
        user.photo_file_size = 1024
      end
    end
  end
end
