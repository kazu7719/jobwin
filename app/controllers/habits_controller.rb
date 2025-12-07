class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show,:edit,:update,:destroy]
  

  def index
    @habits = current_user.habits.order('created_at DESC')
  end

  def new
    @habit = current_user.habits.build
  end

  def create
    @habit = Habit.new(habit_params)
    if @habit.save
      redirect_to habits_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  
  end

  def edit
    
  end

  def update

    if @habit.update(habit_params)
      redirect_to habits_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    redirect_to habits_path
  end


  private

  def habit_params
    params.require(:habit).permit(:habit_name,:start_day).merge(user_id: current_user.id)
  end

  def set_item
    @habit = current_user.habits.find(params[:id])
  end

  

end
