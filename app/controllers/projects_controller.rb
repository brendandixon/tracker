class ProjectsController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  before_filter :ensure_initial_state
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
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @in_edit_mode << @project.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'project' }
      format.json { render json: @project }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    params[:project][:services] = Service.find_all_by_id(params[:project][:services]) if params[:project][:services].present?
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        @was_changed << @project.id
        
        format.html { redirect_to projects_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.js { render 'project' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    params[:project][:services] = Service.find_all_by_id(params[:project][:services]) if params[:project][:services].present?
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        @was_changed << @project.id

        format.html { redirect_to projects_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @in_edit_mode << @project.id

        format.html { render action: "edit" }
        format.js { render 'project' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
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
    query = Project

    services = @filter.content[:services] || []

    query = query.for_services(*services) if services.present?

    query.includes(:supported_services).includes(:services)
    
    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('ASC')
      when 'name' then query = query.in_name_order('DESC')
      end
    end

    @projects = query
  end

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
  end

end
