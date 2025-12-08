FactoryBot.define do
  factory :project do
    project_name { Faker::Lorem.word }
    start_day { Faker::Date.backward(days: 5) }
    schedule_end_day { Faker::Date.forward(days: 10) }
    end_day { Faker::Date.forward(days: 15) }
    memo { Faker::Lorem.sentence }
    association :user
  end
end