class TasksController < ApplicationController

  def index
    @tasks = Task.includes(:user).order('created_at DESC')
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:task_name, :start_day, :schedule_end_day, :end_day, :memo).merge(user_id: current_user.id)
  end
  
end
