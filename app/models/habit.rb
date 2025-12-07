class Habit < ApplicationRecord

  belongs_to :user

  validates :habit_name, presence: true 
  validates :start_day, presence: true 

end
