class HabitsController < ApplicationController

  def index
    @habits = Habit.includes(:user).order('created_at DESC')
  end

  def new
    @habit = Habit.new
  end

  def create
    @habit = Habit.new(habit_params)
    if @habit.save
      redirect_to habits_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def habit_params
    params.require(:habit).permit(:habit_name,:start_day).merge(user_id: current_user.id)
  end

end
