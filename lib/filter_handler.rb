module FilterHandler
  extend ActiveSupport::Concern
  
  INDEX_ACTIONS = [:index]

  included do
    before_filter :initialize_filter
    before_filter :handle_delete, only: :index
    before_filter :handle_reset, only: :index
  end
  
  def initialize_filter
    session[:filter] ||= {}
    session[:filter][self.controller_name] = params[:filter] if params[:filter]
    session[:filter][self.controller_name] ||= {}

    attributes = session[:filter][self.controller_name]

    @filter = (Filter.for_area(self.controller_name).find(attributes['id']) rescue nil) if attributes['id'].present?
    @filter ||= Filter.new(area: self.controller_name)
    @filter.attributes = attributes.reject{|k,v| [:id, 'id'].include?(k)} if attributes.is_a?(Hash) && !attributes.empty?

    normalize_filter

    if params[:commit_filter]
      notice = t(@filter.new_record? ? :created_html : :updated_html, scope: :filter)
      flash[:notice] = notice if @filter.save
    end

    session[:filter][self.controller_name] = @filter.to_hash
  end

  def normalize_filter
    @filter.content ||= {}
    content = @filter.content

    content[:group_by] = (params[:group_by] || content[:group_by]) ? :iteration : nil
    group_by_iteration = content[:group_by] == :iteration

    content[:after] = params[:after] || content[:after]
    content[:before] = params[:before] || content[:before]

    content[:contact_us] = params[:contact_us] || content[:contact_us] || []
    content[:contact_us] = content[:contact_us].split(',') if content[:contact_us].is_a?(String)
    content[:contact_us] = content[:contact_us].map{|cu| cu =~ /^\d+$/ ? cu : nil}.compact
    
    content[:iteration] = params[:iteration] || content[:iteration] || 0
    content[:iteration] = 0 unless content[:iteration] =~ /^(-)?\d+$/
    content[:iteration] = content[:iteration].to_i

    content[:min_points] = params[:min_points] || content[:min_points]
    content[:min_points] = nil unless content[:min_points] =~ /0|1|2|3|4|5/
    content[:max_points] = params[:max_points] || content[:max_points]
    content[:max_points] = nil unless content[:max_points] =~ /0|1|2|3|4|5/

    content[:projects] = params[:projects] || content[:projects] || []
    content[:projects] = content[:projects].split(',') if content[:projects].is_a?(String)
    content[:projects] = content[:projects].map{|p| p.present? ? p : nil}.compact
    content[:projects] = [] if content[:projects].any?{|p| p =~ /all/i}
    content[:projects] = content[:projects].map do |project|
      if project.is_a?(Integer)
        project
      elsif project =~ /^\d+$/
        project.to_i
      else
        Project.with_name(project).all.map{|o| o.id}
      end
    end.flatten.compact

    content[:services] = params[:services] || content[:services] || []
    content[:services] = content[:services].split(',') if content[:services].is_a?(String)
    content[:services] = content[:services].map{|s| s.present? ? s : nil}.compact
    content[:services] = [] if content[:services].any?{|s| s =~ /all/i}
    content[:services] = content[:services].map do |service|
      if service.is_a?(Integer)
        service
      elsif service =~ /^\d+$/
        service.to_i
      else
        service = Service.with_abbreviation(service).first
        service.present? ? service.id : nil
      end
    end.compact

    content[:status] = params[:status] || content[:status] || []
    content[:status] = content[:status].split(',') if content[:status].is_a?(String)
    content[:status] = content[:status].map{|s| s.downcase.to_sym}
    content[:status] = StatusScopes.expand(*content[:status])

    content[:stories] = params[:stories] || content[:stories] || []
    content[:stories] = content[:stories].split(',') if content[:stories].is_a?(String)
    content[:stories] = content[:stories].map{|s| s =~ /^\d+$/ ? s : nil}.compact
    content[:stories] = content[:stories].map{|story| story =~ /^\d+$/ ? story : nil}.flatten.compact

    content[:teams] = params[:teams] || (group_by_iteration ? content[:iteration_team] : nil) || content[:teams] || []
    content[:teams] = content[:teams].split(',') if content[:teams].is_a?(String)
    content[:teams] = content[:teams].map{|t| t.present? ? t : nil}.compact
    content[:teams] = [] if content[:teams].any?{|t| t =~ /all/i}
    content[:teams] = content[:teams].map{|team| team =~ /^\d+$/ ? team : nil}.flatten.compact
    content[:teams] = content[:teams][0...1] || [] if group_by_iteration

    content.delete_if{|k,v| v.blank?}
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  def filters
    Filter.for_area(controller_name).in_name_order
  end

  def handle_delete
    if params[:destroy]
      @filter.destroy rescue nil
      clear_session_filter
    end
  end

  def handle_reset
    if params[:reset]
      params.delete(:filter)
      clear_session_filter
    end
  end

  private

  def clear_session_filter
    @filter = Filter.new(area: self.controller_name)
    session[:filter][self.controller_name] = {}
  end

end
