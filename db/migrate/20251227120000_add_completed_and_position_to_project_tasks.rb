class AddCompletedAndPositionToProjectTasks < ActiveRecord::Migration[7.1]
  class ProjectTask < ApplicationRecord
    self.table_name = "project_tasks"
  end

  def up
    add_column :project_tasks, :completed, :boolean, default: false, null: false
    add_column :project_tasks, :position, :integer, default: 0, null: false
    add_index :project_tasks, [:project_id, :position]

    ProjectTask.reset_column_information
    ProjectTask.order(:project_id, :created_at, :id).group_by(&:project_id).each_value do |tasks|
      tasks.each_with_index do |task, index|
        task.update_columns(position: index + 1)
      end
    end
  end

  def down
    remove_index :project_tasks, column: [:project_id, :position]
    remove_column :project_tasks, :position
    remove_column :project_tasks, :completed
  end
end