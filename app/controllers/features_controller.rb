class FeaturesController < ApplicationController
  DEFAULT_SORT = ['-date']
  STATUS = [:all, :complete, :incomplete]
  
  # GET /features
  # GET /features.json
  def index
    query = Feature

    status = @filter[:status] == :complete || @filter[:status] == :all ? Story::COMPLETED : []
    status += @filter[:status] == :incomplete || @filter[:status] == :all ? Story::INCOMPLETE : []
    query = query.in_status(status) if status.present?

    query = query.for_projects(@filter[:projects].map{|project| project =~ /^\d+$/ ? project : Project.with_name(project).all.map{|o| o.id}}.flatten.compact) if @filter[:projects].present?
    query = query.for_services(@filter[:services].map{|service| service =~ /^\d+$/ ? service : Service.with_abbreviation(service).first.id}.compact) if @filter[:services].present?
    query = query.for_contact_us(@filter[:contact_us].map{|cu| cu =~ /^\d+$/ ? cu : nil}.compact) if @filter[:contact_us].present?

    query = query.after_date(@filter[:after]) if @filter[:after].present?
    query = query.before_date(@filter[:before]) if @filter[:before].present?
    
    @filter[:sort][self.controller_name].each do |sort|
      case sort
      when '-date' then query = query.in_date_order('ASC')
      when 'date' then query = query.in_date_order('DESC')
      when '-feature' then query = query.in_title_order('ASC')
      when 'feature' then query = query.in_title_order('DESC')
      when '-service' then query = query.in_service_order('ASC')
      when 'service' then query = query.in_service_order('DESC')
      end
    end

    @features = query.includes(:service).includes(:projects).uniq.all

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.json { render json: @features }
    end
  end

  # GET /features/1
  # GET /features/1.json
  def show
    @feature = Feature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @feature }
    end
  end

  # GET /features/new
  # GET /features/new.json
  def new
    @feature = Feature.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @feature }
    end
  end

  # GET /features/1/edit
  def edit
    @feature = Feature.find(params[:id])
  end

  # POST /features
  # POST /features.json
  def create
    @feature = Feature.new(params[:feature])

    respond_to do |format|
      if @feature.save
        format.html { redirect_to features_path, notice: 'Feature was successfully created.' }
        format.json { render json: @feature, status: :created, location: @feature }
      else
        format.html { render action: "new" }
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
        format.html { redirect_to features_path, notice: 'Feature was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /features/1
  # DELETE /features/1.json
  def destroy
    @feature = Feature.find(params[:id])
    @feature.destroy

    respond_to do |format|
      format.html { redirect_to features_path }
      format.json { head :no_content }
    end
  end
end
