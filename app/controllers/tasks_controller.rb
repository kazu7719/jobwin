class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show,:edit,:update,:destroy]


  def index
    @tasks = current_user.tasks.order('created_at DESC')
  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    
  end

  def edit
    
  end

  def update

    if @task.update(task_params)
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path
  end

  private

  def task_params
    params.require(:task).permit(:task_name, :start_day, :schedule_end_day, :end_day, :memo).merge(user_id: current_user.id)
  end

  def set_item
    @task = current_user.tasks.find_by(id: params[:id])
    redirect_to(root_path) unless @task
  end


end
