class TeamsController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /teams
  # GET /teams.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @team = Team.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'team' }
      format.json { render json: @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.json
  def new
    @team = Team.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'team' }
      format.json { render json: @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.includes(:projects, :tasks).find(params[:id])
    @edited << @team.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'team' }
      format.json { render json: @team }
    end
  end

  # POST /teams
  # POST /teams.json
  def create
    params[:team][:projects] = Project.find_all_by_id(params[:team][:projects]) if params[:team][:projects].present?
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Team was successfully created.'
        @changed << @team.id
        
        format.html { redirect_to teams_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.js { render 'team' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.json
  def update
    params[:team][:projects] = Project.find_all_by_id(params[:team][:projects]) if params[:team][:projects].present?
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team was successfully updated.'
        @changed << @team.id

        format.html { redirect_to teams_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @team.id

        format.html { render action: "edit" }
        format.js { render 'team' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    
    flash[:notice] = 'Team was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to teams_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = Team

    query = query.includes(:projects, :tasks)

    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('ASC')
      when 'name' then query = query.in_name_order('DESC')
      when '-iteration' then query = query.in_iteration_order('ASC')
      when 'iteration' then query = query.in_iteration_order('DESC')
      when '-velocity' then query = query.in_velocity_order('ASC')
      when 'velocity' then query = query.in_velocity_order('DESC')
      end
    end

    @teams = query
  end

  def ensure_initial_state
    @edited = []
    @changed = []
  end
end
