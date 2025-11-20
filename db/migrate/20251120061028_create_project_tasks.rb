class CreateProjectTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :project_tasks do |t|
      t.string :project_task_name, null: :false
      t.references :user,   null: false, foreign_key: true
      t.references :project,   null: false, foreign_key: true
      t.timestamps
    end
  end
end
