FactoryBot.define do
  factory :user do
    nickname { Faker::Lorem.characters(number: 6) }
    goal { Faker::Lorem.sentence }
    labor_id { 2 }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 6, max_length: 12) }
    password_confirmation { password }
  end
end