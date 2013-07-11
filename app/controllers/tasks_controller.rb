class TasksController < ApplicationController
  def index
  	@tasks = Task.all
  end

  def new
  	@task = Task.new
  end

  def create
  	@task = Task.new(params[:task])
  	if @task.save
	  	redirect_to tasks_path, notice: 'Created a new task.'
	else
		render 'new'
	end

  end

  def edit
  end

  def update
  end

  def destroy
  	task = Task.find params[:id]
  	task.destroy
  	redirect_to tasks_path, notice: 'Deleted task.'
  end
end
