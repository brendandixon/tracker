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

    content[:group_by] = (params[:group_by] || content[:group_by]) ? 'iteration' : nil
    group_by_iteration = content[:group_by] == 'iteration'

    content[:after] = params[:after] || content[:after]
    content[:before] = params[:before] || content[:before]

    content[:contact_us] = params[:contact_us] || content[:contact_us] || []
    content[:contact_us] = content[:contact_us].split(',') if content[:contact_us].is_a?(String)
    content[:contact_us] = Array(content[:contact_us]) unless content[:contact_us].is_a?(Array)
    content[:contact_us] = content[:contact_us].map do |cu|
      if cu.is_a?(Integer)
        cu
      elsif cu =~ /^\d+$/
        cu.to_i
      else
        nil
      end
    end.flatten.compact
    
    content[:min_points] = params[:min_points] || content[:min_points]
    content[:min_points] = nil unless content[:min_points].present? && content[:min_points] =~ /0|1|2|3|4|5/
    content[:max_points] = params[:max_points] || content[:max_points]
    content[:max_points] = nil unless content[:max_points].present? && content[:max_points] =~ /0|1|2|3|4|5/

    content[:projects] = params[:projects] || content[:projects] || []
    content[:projects] = content[:projects].split(',') if content[:projects].is_a?(String)
    content[:projects] = Array(content[:projects]) unless content[:projects].is_a?(Array)
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

    content[:features] = params[:features] || content[:features] || []
    content[:features] = content[:features].split(',') if content[:features].is_a?(String)
    content[:features] = Array(content[:features]) unless content[:features].is_a?(Array)
    content[:features] = content[:features].map{|s| s.present? ? s : nil}.compact
    content[:features] = [] if content[:features].any?{|s| s =~ /all/i}
    content[:features] = content[:features].map do |feature|
      if feature.is_a?(Integer)
        feature
      elsif feature =~ /^\d+$/
        feature.to_i
      else
        feature = Feature.with_name(feature).first
        feature.present? ? feature.id : nil
      end
    end.compact

    content[:status] = params[:status] || content[:status] || []
    content[:status] = content[:status].split(',') if content[:status].is_a?(String)
    content[:status] = Array(content[:status]) unless content[:status].is_a?(Array)
    content[:status] = content[:status].map{|s| s.downcase}
    content[:status] = StatusScopes.expand(*content[:status]).map{|s| s.to_s}

    content[:stories] = params[:stories] || content[:stories] || []
    content[:stories] = content[:stories].split(',') if content[:stories].is_a?(String)
    content[:stories] = Array(content[:stories]) unless content[:stories].is_a?(Array)
    content[:stories] = content[:stories].map do |story|
      if story.is_a?(Integer)
        story
      elsif story =~ /^\d+$/
        story.to_i
      else
        nil
      end
    end.flatten.compact
    
    content[:teams] = params[:teams] || (group_by_iteration ? content[:iteration_team] : nil) || content[:teams] || []
    content[:teams] = content[:teams].split(',') if content[:teams].is_a?(String)
    content[:teams] = Array(content[:teams]) unless content[:teams].is_a?(Array)
    content[:teams] = content[:teams].map{|t| t.present? ? t : nil}.compact
    content[:teams] = [] if content[:teams].any?{|t| t =~ /all/i}
    content[:teams] = content[:teams].map do |team|
      if team.is_a?(Integer)
        team
      elsif team =~ /^\d+$/
        team.to_i
      else
        nil
      end
    end.flatten.compact
    content[:teams] = content[:teams][0...1] || [] if group_by_iteration

    content.delete_if{|k,v| v.blank?}
  end

  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  def shared_filters
    Filter.for_area(controller_name).for_all_users.in_name_order
  end

  def user_filters
    Filter.for_area(controller_name).for_user(current_user).in_name_order
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
