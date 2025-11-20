class Project < ApplicationRecord
  belongs_to :user
  has_many :project_tasks, dependent: :destroy

  validates :project_name, presence: true 
  validates :start_day, presence: true 
  validates :schedule_end_day, presence: true
end
