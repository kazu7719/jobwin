FactoryBot.define do
  factory :task do
    task_name { Faker::Lorem.sentence(word_count: 3) }
    start_day { Faker::Time.backward(days: 5) }
    schedule_end_day { start_day + 2.days }
    end_day { schedule_end_day + 1.day }
    memo { Faker::Lorem.paragraph }
    association :user
  end
end