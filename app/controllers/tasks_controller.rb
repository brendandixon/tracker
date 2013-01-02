class TasksController < ApplicationController
  include FilterHandler

  INDEX_ACTIONS = [:advance, :complete, :create, :destroy, :index, :rank, :update]

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /tasks
  # GET /tasks.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'task' }
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new
    if @filter.content[:projects].present?
      @task.project_id = @filter.content[:projects].first
    elsif @filter.content[:teams].present?
      team = Team.find(@filter.content[:teams].first) rescue nil
      @task.project_id = team.projects.first.id if team.present? && team.projects.present?
    end

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'task' }
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
    @in_edit_mode << @task.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'task' }
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
        # format.js { render 'task' }
        format.js { render 'shared/index' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.js { render 'task' }
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
        # format.js { render 'task' }
        format.js { render 'shared/index' }
        format.json { head :no_content }
      else
        @in_edit_mode << @task.id

        format.html { render action: "edit" }
        format.js { render 'task' }
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
      # format.js { render 'delete' }
      format.js { render 'shared/index' }
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
      format.js { render 'shared/index' }
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
      format.js { render 'shared/index' }
      format.json { render json: @tasks }
    end
    
  end

  # POST /tasks/1/rank?before=xx or /tasks/1/rank?after=xx
  def rank
    @task = Task.rank_between(params[:id], params[:before], params[:after])

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index' }
      format.json { render json: @tasks }
    end
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = Task

    status = if @filter.content[:status] == :complete
              Task::COMPLETED
            elsif @filter.content[:status] == :incomplete
              Task::INCOMPLETE
            elsif @filter.content[:status] == :iteration
              Task::STATUS
            else
              @filter.content[:status]
            end
    query = query.in_status(status) if status.present?
    
    projects = @filter.content[:projects] || []
    services = @filter.content[:services] || []
    stories = @filter.content[:stories] || []
    teams = @filter.content[:teams] || []

    query = query.for_projects(projects) if projects.present?
    query = query.for_services(services) if services.present?
    query = query.for_stories(stories) if stories.present?

    if teams.present?
      query = query.for_teams(teams)
      if teams.length == 1
        @iteration_team = Team.find(teams.first) rescue nil
        query = query.started_on_or_after(@iteration_team.iteration_start_date) if @iteration_team.present?
      end
    end
    
    query = query.at_least_points(@filter.content[:min_points]) if @filter.content[:min_points] =~ /0|1|2|3|4|5/
    query = query.no_more_points(@filter.content[:max_points]) if @filter.content[:max_points] =~ /0|1|2|3|4|5/

    query = query.in_rank_order
    query = query.in_status_order('DESC') if @iteration_team
    
    @tasks = query.includes(:story).includes(:project).uniq
  end

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
    @iteration_team = nil
  end

end
