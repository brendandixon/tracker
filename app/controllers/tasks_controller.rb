class TasksController < ApplicationController
  include FilterHandler
  include ReferencesHandler
  include SortHandler

  DEFAULT_SORT = ['status']
  SORT_FIELDS = ['point', 'status', 'title']

  INDEX_ACTIONS = [:advance, :block, :complete, :create, :destroy, :index, :point, :print, :rank, :unblock, :update]

  load_and_authorize_resource

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /tasks
  # GET /tasks.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'shared/filter'; flash.discard }
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @expanded << @task.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'task'; flash.discard }
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @edited << 'new'
    @expanded << 'new'
    
    if @filter.content[:projects].present?
      @task.project_id = @filter.content[:projects].first
    elsif @filter.content[:teams].present?
      team = Team.find(@filter.content[:teams].first) rescue nil
      @task.project_id = team.projects.first.id if team.present? && team.projects.present?
    end
    
    @task.story_id = @filter.content[:stories].first if @filter.content[:stories].present?

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'task'; flash.discard }
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @edited << @task.id
    @expanded << @task.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'task'; flash.discard }
      format.json { render json: @task }
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        @changed << @task.id
        
        format.html { redirect_to tasks_path(story_id: @task.story_id) }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @task, status: :created, location: @task }
      else
        @edited << 'new'
        @expanded << 'new'
        
        format.html { render action: 'new', template: 'shared/new' }
        format.js { render 'task'; flash.discard }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        @changed << @task.id

        format.html { redirect_to tasks_path(story_id: @task.story_id) }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @task.id
        @expanded << @task.id

        format.html { render action: 'edit', template: 'shared/edit' }
        format.js { render 'task'; flash.discard }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    flash[:notice] = 'Task was successfully deleted.'
    @task.destroy
    
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end
  
  # POST /tasks/1/advance
  def advance
    @task.advance!
    @changed << @task.id

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index'; flash.discard }
      format.json { render json: @tasks }
    end
  end
  
  # POST /tasks/1/block
  def block
    @task.block!
    @changed << @task.id

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index'; flash.discard }
      format.json { render json: @tasks }
    end
  end
  
  # POST /tasks/1/complete
  def complete
    @task.completed!
    @changed << @task.id
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index'; flash.discard }
      format.json { render json: @tasks }
    end
  end

  # POST /tasks/1/point?points=xx
  def point
    @expanded << @task.id if params.has_key?(:expanded)

    respond_to do |format|
      if @task.update_attribute(:points, params[:points].to_i)
        flash[:notice] = "Task set to #{view_context.pluralize(@task.points, 'point')}"
        @changed << @task.id

        format.html { redirect_to tasks_path(story_id: @task.story_id) }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @task.id

        format.html { render action: "edit" }
        format.js { render 'task'; flash.discard }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /tasks/print
  def print
    @iterations = (cookies[:iterations] || '0').split(',').map{|i| i.empty? ? nil : i.to_i}.compact.uniq
    @style = params[:style]
    @style = @style.to_sym if @style.present?
    @style = :cards unless [:cards, :list].include?(@style)

    respond_to do |format|
      format.html { render template: 'shared/print', layout: 'print'}
    end
  end

  # POST /tasks/1/rank?before=xx or /tasks/1/rank?after=xx
  def rank
    @task.rank_between(params[:after], params[:before])
    flash[:notice] = "Unable to move task" unless @task.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index'; flash.discard }
      format.json { render json: @tasks }
    end
  end
  
  # POST /tasks/1/unblock
  def unblock
    @task.unblock!
    @changed << @task.id

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render 'shared/index'; flash.discard }
      format.json { render json: @tasks }
    end
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query

    if @filter.content[:group_by] == 'iteration'
      initial_iteration = (params.has_key?(:initial_iteration) ? params[:initial_iteration].to_i : -3) rescue -3
      query = IterationEnumerator.new(Team.find(@filter.content[:teams].first), initial_iteration) rescue nil
    end

    if query.blank?
      @filter.content[:group_by] = nil if @filter.content[:group_by].present?
      
      query = @tasks || Task

      projects = @filter.content[:projects]
      features = @filter.content[:features]
      status = @filter.content[:status]
      stories = @filter.content[:stories]
      teams = @filter.content[:teams]

      query = query.in_state(status) if status.present?

      query = query.for_features(features) if features.present?
      query = query.for_projects(projects) if projects.present?
      query = query.for_stories(stories) if stories.present?

      query = query.for_teams(teams) if teams.present?
      
      query = query.at_least_points(@filter.content[:min_points]) if @filter.content[:min_points] =~ /0|1|2|3|4|5/
      query = query.no_more_points(@filter.content[:max_points]) if @filter.content[:max_points] =~ /0|1|2|3|4|5/

      @sort.each do |sort|
        case sort
        when 'point' then query = query.in_point_order('ASC')
        when '-point' then query = query.in_point_order('DESC')
        when 'status' then query = query.in_iteration_order('ASC')
        when '-status' then query = query.in_iteration_order('DESC')
        when 'title' then query = query.in_title_order('ASC')
        when '-title' then query = query.in_title_order('DESC')
        end
      end

      query = query.includes(:feature, :project, :references).uniq
    end

    @tasks = query
  end

  def ensure_initial_state
    @changed = []
    @edited = []
    @expanded = []
    @iterations = [0]
  end

end
