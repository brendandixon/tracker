class TasksController < ApplicationController
  DEFAULT_SORT = ['-project']

  # GET /tasks
  # GET /tasks.json
  def index
    stories = params[:stories]
    stories = stories.split(',') if stories.is_a?(String)

    query = Task

    unless stories.present?
      status = @filter[:status] == :complete || @filter[:status] == :all ? Task::COMPLETED : []
      status += @filter[:status] == :incomplete || @filter[:status] == :all ? Task::INCOMPLETE : []
      query = query.in_status(status) if status.present?
    end

    query = query.for_stories(stories.map{|story| story =~ /^\d+$/ ? story : nil}.flatten.compact) if stories.present?
    query = query.for_projects(@filter[:projects].map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if @filter[:projects].present?
    query = query.for_services(@filter[:services].map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if @filter[:services].present?

    @filter[:sort][self.controller_name].each do |sort|
      case sort
      when '-story' then query = query.in_story_order('ASC')
      when 'story' then query = query.in_story_order('DESC')
      when '-project' then query = query.in_project_order('ASC')
      when 'project' then query = query.in_project_order('DESC')
      when '-service' then query = query.in_service_order('ASC')
      when 'service' then query = query.in_service_order('DESC')
      when '-status' then query = query.in_status_order('ASC')
      when 'status' then query = query.in_status_order('DESC')
      end
    end
    
    @tasks = query.includes(:story).includes(:project).uniq.all

    respond_to do |format|
      format.html { render 'shared/index'}
      format.js # index.js.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path(story_id: @task.story_id), notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to tasks_path(story_id: @task.story_id), notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.json { head :no_content }
    end
  end
  
  # POST /tasks/1/advance
  def advance
    @task = Task.find(params[:id])
    @task.advance!
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'task.js.erb' }
      format.json { render json: @tasks }
    end
    
  end
  
  # POST /tasks/1/complete
  def complete
    @task = Task.find(params[:id])
    @task.completed!
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'task.js.erb' }
      format.json { render json: @tasks }
    end
    
  end
end
