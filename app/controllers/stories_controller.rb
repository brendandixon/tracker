class StoriesController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['-date']
  
  # GET /stories
  # GET /stories.json
  def index
    query = Story

    status = if @filter.content[:status] == :complete
              Task::COMPLETED
            elsif @filter.content[:status] == :incomplete
              Task::INCOMPLETE
            else
              []
            end
    query = query.in_status(status) if status.present?
    
    projects = @filter.content[:projects] || []
    projects = projects.map{|p| p.present? ? p : nil}.compact
    projects = nil if projects.any?{|p| p =~ /all/i}
    
    services = @filter.content[:services] || []
    services = services.map{|s| s.present? ? s : nil}.compact
    services = nil if services.any?{|s| s =~ /all/i}

    query = query.for_projects(projects.map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if projects.present?
    query = query.for_services(services.map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if services.present?
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
      when '-service' then query = query.in_service_order('ASC')
      when 'service' then query = query.in_service_order('DESC')
      end
    end

    @stories = query.includes(:service).includes(:projects).uniq.all
    
    respond_to do |format|
      format.html { render 'shared/index' }
      format.js { render @filter.errors.empty? ? 'index' : 'filter' }
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
