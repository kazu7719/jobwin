class HabitChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit

  def update
    check_date = parsed_check_date
    return render json: { errors: ["check_date is invalid"] }, status: :unprocessable_entity if check_date.blank?

    habit_check = @habit.habit_checks.find_or_initialize_by(check_date: check_date)
    habit_check.completed = ActiveModel::Type::Boolean.new.cast(params[:completed])

    if habit_check.save
      render json: progress_payload
    else
      render json: { errors: habit_check.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_habit
    @habit = current_user.habits.includes(:habit_checks).find_by(id: params[:habit_id])
    return head :not_found unless @habit
  end

  def parsed_check_date
    Date.parse(params[:check_date])
  rescue ArgumentError, TypeError
    nil
  end

  def progress_payload
    return { progress_text: "開始日を設定してください", checked_count: 0, total_days: 0 } if @habit.start_day.blank?

    total_days = [(@habit.start_day.to_date <= Date.current ? (Date.current - @habit.start_day.to_date).to_i + 1 : 0), 0].max
    checked_count = @habit.habit_checks.completed.where("check_date <= ?", Date.current).count
    percentage = total_days.positive? ? ((checked_count.to_f / total_days) * 100).round : nil

    {
      progress_text: total_days.positive? ? "#{checked_count} / #{total_days}日 (#{percentage}%)" : "開始日を設定してください",
      checked_count: checked_count,
      total_days: total_days
    }
  end
end