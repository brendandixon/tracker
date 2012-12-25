class StoriesController < ApplicationController
  DEFAULT_SORT = ['-date']
  
  # GET /stories
  # GET /stories.json
  def index
    query = Story

    status = if @filter[:status] == :complete
              Task::COMPLETED
            elsif @filter[:status] == :incomplete
              Task::INCOMPLETE
            else
              []
            end
    query = query.in_status(status) if status.present?

    query = query.for_projects(@filter[:projects].map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if @filter[:projects].present?
    query = query.for_services(@filter[:services].map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if @filter[:services].present?
    query = query.for_contact_us(@filter[:contact_us].map{|cu| cu =~ /^\d+$/ ? cu : nil}.compact) if @filter[:contact_us].present?

    query = query.after_date(@filter[:after]) if @filter[:after].present?
    query = query.before_date(@filter[:before]) if @filter[:before].present?
    
    @sort.each do |sort|
      case sort
      when '-cu' then query = query.in_contact_us_order('ASC')
      when 'cu' then query = query.in_contact_us_order('DESC')
      when '-date' then query = query.in_date_order('ASC')
      when 'date' then query = query.in_date_order('DESC')
      when '-story' then query = query.in_title_order('ASC')
      when 'story' then query = query.in_title_order('DESC')
      when '-service' then query = query.in_service_order('ASC')
      when 'service' then query = query.in_service_order('DESC')
      end
    end

    @stories = query.includes(:service).includes(:projects).uniq.all
    
    respond_to do |format|
      format.html { render 'shared/index' }
      format.js # index.js.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @story = Story.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.json { render json: @story }
    end
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
end
