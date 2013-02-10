class ReferenceTypesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['name']
  SORT_FIELDS = ['name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  load_and_authorize_resource

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /reference_types
  # GET /reference_types.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @reference_types }
    end
  end

  # GET /reference_types/1
  # GET /reference_types/1.json
  def show
    @expanded << @reference_type.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'reference_type' }
      format.json { render json: @reference_type }
    end
  end

  # GET /reference_types/new
  # GET /reference_types/new.json
  def new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'reference_type' }
      format.json { render json: @reference_type }
    end
  end

  # GET /reference_types/1/edit
  def edit
    @edited << @reference_type.id
    @expanded << @reference_type.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'reference_type' }
      format.json { render json: @reference_type }
    end
  end

  # POST /reference_types
  # POST /reference_types.json
  def create
    respond_to do |format|
      if @reference_type.save
        flash[:notice] = 'Reference type was successfully created.'
        @changed << @reference_type.id
        
        format.html { redirect_to reference_types_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @reference_type, status: :created, location: @reference_type }
      else
        @edited << 'new'
        @expanded << 'new'

        format.html { render action: 'new', template: 'shared/new' }
        format.js { render 'reference_type' }
        format.json { render json: @reference_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reference_types/1
  # PUT /reference_types/1.json
  def update
    respond_to do |format|
      if @reference_type.update_attributes(params[:reference_type])
        flash[:notice] = 'Reference type was successfully updated.'
        @changed << @reference_type.id

        format.html { redirect_to reference_types_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @reference_type.id
        @expanded << @reference_type.id

        format.html { render action: 'edit', template: 'shared/edit' }
        format.js { render 'reference_type' }
        format.json { render json: @reference_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reference_types/1
  # DELETE /reference_types/1.json
  def destroy
    @reference_type.destroy

    flash[:notice] = 'Reference type was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to reference_types_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end


  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = @reference_types || ReferenceType

    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('DESC')
      when 'name' then query = query.in_name_order('ASC')
      end
    end

    @reference_types = query
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
