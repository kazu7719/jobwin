class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(:user).order('created_at DESC')
  end

  def new
    @project = Project.new
  end
end
