FactoryBot.define do
  factory :habit_check do
    association :habit
    check_date { Date.current }
    completed { true }
  end
end