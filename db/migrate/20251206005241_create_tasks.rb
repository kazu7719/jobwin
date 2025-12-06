class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :task_name,   null: :false
      t.datetime :start_day,    null: :false
      t.datetime :schedule_end_day,    null: :false
      t.datetime :end_day 
      t.text :memo
      t.references :user,    null: false, foreign_key: true
      t.timestamps
    end
  end
end
