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

    content[:iteration_mode] = true if content[:iteration_mode].present?

    if content[:iteration_mode]
      content[:iteration] ||= {}
      content[:iteration][:number] = params[:iteration_number] || content[:iteration][:number] || 0
      content[:iteration][:number] = 0 unless content[:iteration_number] =~ /^(-)?\d+$/
      content[:iteration][:number] = content[:iteration][:number].to_i

      content[:iteration][:status] = params[:iteration_status] || content[:iteration][:status] || []
      content[:iteration][:status] = content[:iteration][:status].downcase.to_sym if content[:iteration][:status].is_a?(String)
      content[:iteration][:status] = StatusScopes.cleanse(*content[:iteration][:status])

      content[:iteration][:team] = params[:iteration_team] || content[:iteration][:team] || nil
      content[:iteration][:team] = nil unless content[:iteration][:team] =~ /^\d+$/

      content[:iteration] = content[:iteration].keep_if {|k, v| ['number', 'status', 'team'].include?(k)}
    else
      content[:after] = params[:after] || content[:after]
      content[:before] = params[:before] || content[:before]

      content[:contact_us] = params[:contact_us] || content[:contact_us]
      content[:contact_us] = content[:contact_us].split(',') if content[:contact_us].is_a?(String)

      content[:iteration] = {}

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
      content[:status] = content[:status].downcase.to_sym if content[:status].is_a?(String)
      content[:status] = StatusScopes.cleanse(*content[:status])

      content[:stories] = params[:stories] || content[:stories] || []
      content[:stories] = content[:stories].split(',') if content[:stories].is_a?(String)
      content[:stories] = content[:stories].map{|s| s =~ /^\d+$/ ? s : nil}.compact
      content[:stories] = content[:stories].map{|story| story =~ /^\d+$/ ? story : nil}.flatten.compact

      content[:teams] = params[:teams] || content[:teams] || []
      content[:teams] = content[:teams].split(',') if content[:teams].is_a?(String)
      content[:teams] = content[:teams].map{|t| t.present? ? t : nil}.compact
      content[:teams] = [] if content[:teams].any?{|t| t =~ /all/i}
      content[:teams] = content[:teams].map{|team| team =~ /^\d+$/ ? team : nil}.flatten.compact
    end
    
    @filter.content = content.reject{|k, v| v.blank?}
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
