FactoryBot.define do
  factory :project_task do
    project_task_name { Faker::Lorem.sentence }
    association :user
    association :project
  end
end