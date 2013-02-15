class StoriesController < ApplicationController
  include FilterHandler
  include ReferencesHandler
  include SortHandler

  DEFAULT_SORT = ['date']
  SORT_FIELDS = ['date', 'feature', 'reference', 'title']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  load_and_authorize_resource

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS
  
  # GET /stories
  # GET /stories.json
  def index
    respond_to do |format|
      format.html { render 'shared/index' }
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter'; flash.discard }
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @expanded << @story.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'story'; flash.discard }
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'story'; flash.discard }
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @edited << @story.id
    @expanded << @story.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'story'; flash.discard }
      format.json { render json: @story }
    end
  end

  # POST /stories
  # POST /stories.json
  def create
    respond_to do |format|
      if @story.save
        flash[:notice] = 'Story was successfully created.'
        @changed << @story.id

        format.html { redirect_to stories_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @story, status: :created, location: @story }
      else
        @edited << 'new'
        @expanded << 'new'

        format.html { render action: 'new', template: 'shared/new' }
        format.js { render 'story'; flash.discard }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    respond_to do |format|
      if @story.update_attributes(params[:story])
        flash[:notice] = 'Story was successfully updated.'
        @changed << @story.id
        
        format.html { redirect_to stories_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @story.id
        @expanded << @story.id

        format.html { render action: 'edit', template: 'shared/edit' }
        format.js { render 'story'; flash.discard }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story.destroy

    flash[:notice] = 'Story was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to stories_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = @stories || Story

    contact_us = @filter.content[:contact_us]
    projects = @filter.content[:projects]
    features = @filter.content[:features]
    status = @filter.content[:status]

    if status.present?
      query = projects.present? ? query.has_tasks_in_state_for_projects(status, projects) : query.has_tasks_in_state(status)
    end

    query = query.for_contact_us(contact_us) if contact_us.present?
    query = query.for_features(features) if features.present?
    query = query.for_projects(projects) if projects.present?

    query = query.on_or_after_date(@filter.content[:after]) if @filter.content[:after].present?
    query = query.on_or_before_date(@filter.content[:before]) if @filter.content[:before].present?
    
    @sort.each do |sort|
      case sort
      when '-date' then query = query.in_date_order('DESC')
      when 'date' then query = query.in_date_order('ASC')
      when '-feature' then query = query.in_feature_order('DESC')
      when 'feature' then query = query.in_feature_order('ASC')
      when '-reference' then query = query.in_reference_order('DESC')
      when 'reference' then query = query.in_reference_order('ASC')
      when '-title' then query = query.in_title_order('DESC')
      when 'title' then query = query.in_title_order('ASC')
      end
    end

    @stories = query.includes(:feature, :references, :tasks).uniq
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
