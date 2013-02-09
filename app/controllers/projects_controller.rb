class ProjectsController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-name']
  SORT_FIELDS = ['name', '-name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  load_and_authorize_resource

  before_filter :ensure_initial_state
  before_filter :ensure_features
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /projects
  # GET /projects.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @expanded << @project.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @edited << @project.id
    @expanded << @project.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        @changed << @project.id
        
        format.html { redirect_to projects_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @project, status: :created, location: @project }
      else
        @edited << 'new'
        @expanded << 'new'

        format.html { render action: "new" }
        format.js { render 'project' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        @changed << @project.id

        format.html { redirect_to projects_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @project.id
        @expanded << @project.id

        format.html { render action: "edit" }
        format.js { render 'project' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    flash[:notice] = 'Project was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = @projects || Project

    features = @filter.content[:features] || []

    query = query.for_features(*features) if features.present?

    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('ASC')
      when 'name' then query = query.in_name_order('DESC')
      end
    end

    @projects = query.includes(:features, :stories, :tasks)
  end

  def ensure_features
    params[:project][:features] = Feature.find_all_by_id(params[:project][:features]) if params.present? && params[:project].present? && params[:project][:features].present?
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
