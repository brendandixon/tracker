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

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'story' }
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
    @in_edit_mode << @story.id

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
        @was_changed << @story.id

        format.html { redirect_to stories_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @story, status: :created, location: @story }
      else
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
        @was_changed << @story.id
        
        format.html { redirect_to stories_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
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

    status = (@filter.content[:status] || []).first
    if status == :complete
      query = query.joins(:tasks).completed
    elsif status == :incomplete
      query = query.joins(:tasks).incomplete
    elsif status.present?
      query = query.joins(:tasks).in_state(status)
    end

    projects = @filter.content[:projects] || []
    services = @filter.content[:services] || []

    query = query.for_projects(projects) if projects.present?
    query = query.for_services(services) if services.present?
    query = query.for_contact_us(@filter.content[:contact_us].map{|cu| cu =~ /^\d+$/ ? cu : nil}.compact) if @filter.content[:contact_us].present?

    query = query.on_or_after_date(@filter.content[:after]) if @filter.content[:after].present?
    query = query.on_or_before_date(@filter.content[:before]) if @filter.content[:before].present?
    
    @sort.each do |sort|
      case sort
      when '-cu' then query = query.in_contact_us_order('ASC')
      when 'cu' then query = query.in_contact_us_order('DESC')
      when '-date' then query = query.in_date_order('ASC')
      when 'date' then query = query.in_date_order('DESC')
      when '-story' then query = query.in_title_order('ASC')
      when 'story' then query = query.in_title_order('DESC')
      when '-service' then query = query.in_abbreviation_order('ASC')
      when 'service' then query = query.in_abbreviation_order('DESC')
      end
    end

    @stories = query.includes(:service).includes(:projects).uniq
  end

  def ensure_initial_state
    @in_edit_mode = []
    @was_changed = []
  end

end
