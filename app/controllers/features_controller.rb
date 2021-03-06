class FeaturesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['name']
  SORT_FIELDS = ['category', 'name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  load_and_authorize_resource

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /features
  # GET /features.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @features }
    end
  end

  # GET /features/1
  # GET /features/1.json
  def show
    @expanded << @feature.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # GET /features/new
  # GET /features/new.json
  def new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # GET /features/1/edit
  def edit
    @edited << @feature.id
    @expanded << @feature.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # POST /features
  # POST /features.json
  def create
    respond_to do |format|
      if @feature.save
        flash[:notice] = 'Feature was successfully created.'
        @changed << @feature.id
        
        format.html { redirect_to features_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @feature, status: :created, location: @feature }
      else
        @edited << 'new'
        @expanded << 'new'

        format.html { render action: 'new', template: 'shared/new' }
        format.js { render 'feature' }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /features/1
  # PUT /features/1.json
  def update
    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        flash[:notice] = 'Feature was successfully updated.'
        @changed << @feature.id

        format.html { redirect_to features_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @feature.id
        @expanded << @feature.id

        format.html { render action: 'edit', template: 'shared/edit' }
        format.js { render 'feature' }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /features/1
  # DELETE /features/1.json
  def destroy
    @feature.destroy

    flash[:notice] = 'Feature was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to features_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end


  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = @features || Feature
    
    @sort.each do |sort|
      case sort
      when '-category' then query = query.in_category_order('DESC')
      when 'category' then query = query.in_category_order('ASC')
      when '-name' then query = query.in_name_order('DESC')
      when 'name' then query = query.in_name_order('ASC')
      end
    end

    @features = query.includes(:category, :projects, :stories)
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
