class ProjectTask < ApplicationRecord

  belongs_to :user
  belongs_to :project

  validates :project_task_name, presence: true
  validates :position, numericality: { greater_than: 0 }

  before_validation :set_default_position, on: :create

  private

  def set_default_position
    return if position.present? && position.positive?
    return unless project

    existing_positions = project.project_tasks.map(&:position).compact
    self.position = existing_positions.max.to_i + 1
  end
end
