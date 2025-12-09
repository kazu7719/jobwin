class Project < ApplicationRecord
  belongs_to :user
  has_many :project_tasks, -> { order(:position, :created_at) }, dependent: :destroy

  accepts_nested_attributes_for :project_tasks, allow_destroy: true

  validates :project_name, presence: true 
  validates :start_day, presence: true 
  validates :schedule_end_day, presence: true
end
