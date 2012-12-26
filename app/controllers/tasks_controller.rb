class TasksController < ApplicationController
  include FilterHandler

  before_filter :ensure_initial_state

  # GET /tasks
  # GET /tasks.json
  def index
    stories = params[:stories]
    stories = stories.split(',') if stories.is_a?(String)

    query = Task

    unless stories.present?
      status = if @filter.content[:status] == :complete
                Task::COMPLETED
              elsif @filter.content[:status] == :incomplete
                Task::INCOMPLETE
              else
                []
              end
      query = query.in_status(status) if status.present?
    end
    
    projects = @filter.content[:projects] || []
    projects = projects.map{|p| p.present? ? p : nil}.compact
    projects = nil if projects.any?{|p| p =~ /all/i}
    
    services = @filter.content[:services] || []
    services = services.map{|s| s.present? ? s : nil}.compact
    services = nil if services.any?{|s| s =~ /all/i}

    query = query.for_stories(stories.map{|story| story =~ /^\d+$/ ? story : nil}.flatten.compact) if stories.present?
    query = query.for_projects(projects.map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if projects.present?
    query = query.for_services(services.map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if services.present?

    query = query.in_rank_order
    
    @tasks = query.includes(:story).includes(:project).uniq

    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'index' : 'filter' }
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'task.js.erb' }
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
    @in_edit_mode << @task.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'task.js.erb' }
      format.json { render json: @task }
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        @was_changed << @task.id
        
        format.html { redirect_to tasks_path(story_id: @task.story_id) }
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
        flash[:notice] = 'Task was successfully updated.'
        @was_changed << @task.id

        format.html { redirect_to tasks_path(story_id: @task.story_id) }
        format.js { render 'task.js.erb' }
        format.json { head :no_content }
      else
        @in_edit_mode << @task.id

        format.html { render action: "edit" }
        format.js { render 'task.js.erb' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    
    flash[:notice] = 'Task was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.js { render 'delete.js.erb' }
      format.json { head :no_content }
    end
  end
  
  # POST /tasks/1/advance
  def advance
    @task = Task.find(params[:id])
    @task.advance!
    @was_changed << @task.id

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
    @was_changed << @task.id
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'task.js.erb' }
      format.json { render json: @tasks }
    end
    
  end

  # POST /tasks/1/rank?before=xx or /tasks/1/rank?after=xx
  def rank
    @task = Task.rank_between(params[:id], params[:before], params[:after])

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'task.js.erb' }
      format.json { render json: @tasks }
    end
  end

  private

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
  end
end
