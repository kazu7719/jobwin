class ProjectTask < ApplicationRecord

  belongs_to :user
  belongs_to :project

  validates :project_task_name, presence: true
end
