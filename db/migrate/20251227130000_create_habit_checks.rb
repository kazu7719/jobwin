class CreateHabitChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :habit_checks do |t|
      t.references :habit, null: false, foreign_key: true
      t.date :check_date, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :habit_checks, [:habit_id, :check_date], unique: true
  end
end