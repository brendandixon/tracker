class StoriesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-date']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS
  
  # GET /stories
  # GET /stories.json
  def index
    respond_to do |format|
      format.html { render 'shared/index' }
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @story = Story.find(params[:id])
    @expanded << @story.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'story' }
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'story' }
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
    @edited << @story.id
    @expanded << @story.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'story' }
      format.json { render json: @story }
    end
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(params[:story])

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

        format.html { render action: "new" }
        format.js { render 'story' }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @story = Story.find(params[:id])

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

        format.html { render action: "edit" }
        format.js { render 'story' }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find(params[:id])
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
    query = Story

    contact_us = @filter.content[:contact_us]
    projects = @filter.content[:projects]
    features = @filter.content[:features]
    status = @filter.content[:status]

    query = query.has_tasks_in_state(status)

    query = query.for_contact_us(contact_us) if contact_us.present?
    query = query.for_features(features) if features.present?
    query = query.for_projects(projects) if projects.present?

    query = query.on_or_after_date(@filter.content[:after]) if @filter.content[:after].present?
    query = query.on_or_before_date(@filter.content[:before]) if @filter.content[:before].present?
    
    @sort.each do |sort|
      case sort
      when 'cu' then query = query.in_contact_us_order('ASC')
      when '-cu' then query = query.in_contact_us_order('DESC')
      when 'date' then query = query.in_date_order('ASC')
      when '-date' then query = query.in_date_order('DESC')
      when 'story' then query = query.in_title_order('ASC')
      when '-story' then query = query.in_title_order('DESC')
      when 'feature' then query = query.in_feature_order('ASC')
      when '-feature' then query = query.in_feature_order('DESC')
      end
    end

    @stories = query.includes(:feature, :tasks).uniq
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
