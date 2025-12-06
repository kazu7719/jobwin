class Task < ApplicationRecord
  belongs_to :user

  validates :task_name, presence: true 
  validates :start_day, presence: true 
  validates :schedule_end_day, presence: true
end
