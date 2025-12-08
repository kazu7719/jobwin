FactoryBot.define do
  factory :habit do
    habit_name { Faker::Lorem.word }
    start_day { Faker::Time.between(from: 1.week.ago, to: Time.zone.now) }
    association :user
  end
end