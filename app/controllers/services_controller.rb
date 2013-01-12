class ServicesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-abbreviation']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /services
  # GET /services.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @services }
    end
  end

  # GET /services/1
  # GET /services/1.json
  def show
    @service = Service.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'service' }
      format.json { render json: @service }
    end
  end

  # GET /services/new
  # GET /services/new.json
  def new
    @service = Service.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'service' }
      format.json { render json: @service }
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    @in_edit_mode << @service.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'service' }
      format.json { render json: @service }
    end
  end

  # POST /services
  # POST /services.json
  def create
    @service = Service.new(params[:service])

    respond_to do |format|
      if @service.save
        flash[:notice] = 'Service was successfully created.'
        @was_changed << @service.id
        
        format.html { redirect_to services_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @service, status: :created, location: @service }
      else
        format.html { render action: "new" }
        format.js { render 'service' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /services/1
  # PUT /services/1.json
  def update
    @service = Service.find(params[:id])

    respond_to do |format|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Service was successfully updated.'
        @was_changed << @service.id

        format.html { redirect_to services_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @in_edit_mode << @service.id

        format.html { render action: "edit" }
        format.js { render 'service' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service = Service.find(params[:id])
    @service.destroy

    flash[:notice] = 'Service was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to services_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end


  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = Service
    
    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('ASC')
      when 'name' then query = query.in_name_order('DESC')
      when '-abbreviation' then query = query.in_abbreviation_order('ASC')
      when 'abbreviation' then query = query.in_abbreviation_order('DESC')
      end
    end

    @services = query.includes(:projects, :stories)
  end

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
  end

end
