class CalendarsController < ApplicationController
  def index
    @today = Date.current
    @month_date = requested_month || @today.beginning_of_month
    @month_label = @month_date.strftime("%Y年%-m月")
    @days_in_month = @month_date.end_of_month.day
    @leading_blank_cells = @month_date.wday
    @total_cells = ((@leading_blank_cells + @days_in_month) / 7.0).ceil * 7
    @prev_month_param = (@month_date - 1.month).strftime("%Y-%m")
    @next_month_param = (@month_date + 1.month).strftime("%Y-%m")


    @calendar_entries = Hash.new { |hash, date| hash[date] = { projects: [], tasks: [], habits: [] } }

    build_calendar_entries if user_signed_in?
  end

  private

  def build_calendar_entries
    month_range = @month_date.beginning_of_month..@month_date.end_of_month

    current_user.projects.find_each do |project|
      add_span_entry(month_range, project.start_day, project.schedule_end_day, :projects, project.project_name, project.id)
    end

    Task.where(user_id: current_user.id).find_each do |task|
      add_span_entry(month_range, task.start_day, task.schedule_end_day, :tasks, task.task_name, task.id)
    end

    Habit.where(user_id: current_user.id).find_each do |habit|
      add_span_entry(month_range, habit.start_day, month_range.last, :habits, habit.habit_name, habit.id)
    end
  end

  def add_span_entry(month_range, start_day, end_day, type_key, label, identifier)
    return if start_day.blank? || end_day.blank?

    range_start = [start_day.to_date, month_range.first].max
    range_end = [end_day.to_date, month_range.last].min
    return if range_end < range_start

    (range_start..range_end).each do |date|
      @calendar_entries[date][type_key] << { id: identifier, name: label }
    end
  end

  def add_single_entry(month_range, day, type_key, label, identifier)
    return if day.blank?

    date = day.to_date
    return unless month_range.cover?(date)

    @calendar_entries[date][type_key] << { id: identifier, name: label }
  end

  def requested_month
    return if params[:month].blank?

    Date.strptime(params[:month], "%Y-%m").beginning_of_month
  rescue ArgumentError
    nil
  end
end
