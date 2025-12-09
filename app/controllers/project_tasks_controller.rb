class ProjectTasksController < ApplicationController

  before_action :authenticate_user!
  before_action :set_project
  before_action :set_project_task, only: :update

  def create
  end

  def update
    if @project_task.update(project_task_params)
      head :no_content
    else
      render json: { errors: @project_task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sort
    task_ids = Array(params[:project_task_ids])

    ProjectTask.transaction do
      task_ids.each_with_index do |task_id, index|
        task = @project.project_tasks.find(task_id)
        task.update!(position: index + 1)
      end
    end

    head :no_content
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render json: { error: "Invalid task order" }, status: :unprocessable_entity
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_project_task
    @project_task = @project.project_tasks.find(params[:id])
  end

  def project_task_params
    params.require(:project_task).permit(:completed)
  end
end
