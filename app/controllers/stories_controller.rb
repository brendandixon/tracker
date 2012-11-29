class StoriesController < ApplicationController
  DEFAULT_SORT = ['-project']

  # GET /stories
  # GET /stories.json
  def index
    features = params[:features]
    features = features.split(',') if features.is_a?(String)

    query = Story

    unless features.present?
      status = @filter[:status] == :complete || @filter[:status] == :all ? Story::COMPLETED : []
      status += @filter[:status] == :incomplete || @filter[:status] == :all ? Story::INCOMPLETE : []
      query = query.in_status(status) if status.present?
    end

    query = query.for_features(features.map{|feature| feature =~ /^\d+$/ ? feature : nil}.flatten.compact) if features.present?
    query = query.for_projects(@filter[:projects].map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if @filter[:projects].present?
    query = query.for_services(@filter[:services].map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if @filter[:services].present?

    @filter[:sort][self.controller_name].each do |sort|
      case sort
      when '-feature' then query = query.in_feature_order('ASC')
      when 'feature' then query = query.in_feature_order('DESC')
      when '-project' then query = query.in_project_order('ASC')
      when 'project' then query = query.in_project_order('DESC')
      when '-service' then query = query.in_service_order('ASC')
      when 'service' then query = query.in_service_order('DESC')
      when '-status' then query = query.in_status_order('ASC')
      when 'status' then query = query.in_status_order('DESC')
      end
    end
    
    @stories = query.includes(:feature).includes(:project).uniq.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @story = Story.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(params[:story])

    respond_to do |format|
      if @story.save
        format.html { redirect_to stories_path, notice: 'Story was successfully created.' }
        format.json { render json: @story, status: :created, location: @story }
      else
        format.html { render action: "new" }
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
        format.html { redirect_to stories_path, notice: 'Story was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find(params[:id])
    @story.destroy

    respond_to do |format|
      format.html { redirect_to stories_path }
      format.json { head :no_content }
    end
  end
  
  # POST /stories/1/advance
  def advance
    @story = Story.find(params[:id])
    @story.advance!
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: @stories }
    end
    
  end
end
