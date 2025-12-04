class ProjectsController < ApplicationController
  before_action :authenticate_user!
  def index
    @projects = Project.includes(:user).order('created_at DESC')
  end

  def new
    @project = current_user.projects.build
    @project.project_tasks.build if @project.project_tasks.empty?
  end


  def create
    @project = current_user.projects.build(project_params)
    assign_task_users
    build_default_task if @project.project_tasks.empty?

    if @project.save
      redirect_to projects_path
    else
      render :new, status: :unprocessable_entity
    end  
  end

  private

  def build_default_task
    @project.project_tasks.build(user: current_user) if @project.project_tasks.empty?
  end

  def assign_task_users
    @project.project_tasks.each { |task| task.user ||= current_user }
  end
  
  def project_params
    params.require(:project).permit(:project_name, :start_day, :schedule_end_day, :end_day, :memo,project_tasks_attributes: [:id, :project_task_name, :_destroy]).merge(user_id: current_user.id)
  end
  
end
