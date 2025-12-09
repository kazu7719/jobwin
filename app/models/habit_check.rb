class HabitCheck < ApplicationRecord
  belongs_to :habit

  validates :check_date, presence: true, uniqueness: { scope: :habit_id }
  validate :check_date_not_before_habit_start

  scope :completed, -> { where(completed: true) }

  private

  def check_date_not_before_habit_start
    return if habit.blank? || check_date.blank? || habit.start_day.blank?
    errors.add(:check_date, "must be on or after the habit start day") if check_date < habit.start_day.to_date
  end
end