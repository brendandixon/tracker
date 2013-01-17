class FeaturesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['name']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

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
    @feature = Feature.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # GET /features/new
  # GET /features/new.json
  def new
    @feature = Feature.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # GET /features/1/edit
  def edit
    @feature = Feature.find(params[:id])
    @in_edit_mode << @feature.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'feature' }
      format.json { render json: @feature }
    end
  end

  # POST /features
  # POST /features.json
  def create
    @feature = Feature.new(params[:feature])

    respond_to do |format|
      if @feature.save
        flash[:notice] = 'Feature was successfully created.'
        @was_changed << @feature.id
        
        format.html { redirect_to features_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @feature, status: :created, location: @feature }
      else
        format.html { render action: "new" }
        format.js { render 'feature' }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /features/1
  # PUT /features/1.json
  def update
    @feature = Feature.find(params[:id])

    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        flash[:notice] = 'Feature was successfully updated.'
        @was_changed << @feature.id

        format.html { redirect_to features_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @in_edit_mode << @feature.id

        format.html { render action: "edit" }
        format.js { render 'feature' }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /features/1
  # DELETE /features/1.json
  def destroy
    @feature = Feature.find(params[:id])
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
    query = Feature
    
    @sort.each do |sort|
      case sort
      when '-name' then query = query.in_name_order('ASC')
      when 'name' then query = query.in_name_order('DESC')
      end
    end

    @features = query.includes(:projects, :stories)
  end

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
  end

end
