class Habit < ApplicationRecord

  belongs_to :user
  has_many :habit_checks, dependent: :destroy

  validates :habit_name, presence: true 
  validates :start_day, presence: true 

end
