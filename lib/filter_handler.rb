module FilterHandler
  extend ActiveSupport::Concern

  included do
    before_filter :initialize_filter, only: [:index, :delete_filter, :reset_filter]
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

    @filter.save if params[:commit]

    session[:filter][self.controller_name] = @filter.to_hash
  end

  def normalize_filter
    @filter.content ||= {}
    content = @filter.content
    
    content[:after] = params[:after] || content[:after]
    content[:before] = params[:before] || content[:before]

    content[:contact_us] = params[:contact_us] || content[:contact_us]
    content[:contact_us] = content[:contact_us].split(',') if content[:contact_us].is_a?(String)

    content[:projects] = params[:projects] || content[:projects] || []
    content[:projects] = content[:projects].split(',') if content[:projects].is_a?(String)
    content[:projects] = content[:projects].map{|p| p.present? ? p : nil}.compact
    content[:projects] = nil if content[:projects].any?{|p| p =~ /all/i}

    content[:services] = params[:services] || content[:services] || []
    content[:services] = content[:services].split(',') if content[:services].is_a?(String)
    content[:services] = content[:services].map{|s| s.present? ? s : nil}.compact
    content[:services] = nil if content[:services].any?{|s| s =~ /all/i}

    content[:status] = params[:status] || content[:status]
    content[:status] = content[:status].downcase.to_sym if content[:status].is_a?(String)

    content[:stories] = params[:stories] || content[:stories] || []
    content[:stories] = content[:stories].split(',') if content[:stories].is_a?(String)
    content[:stories] = content[:stories].map{|s| s =~ /^\d+$/ ? s : nil}.compact

    @filter.content = content.reject{|k, v| v.blank?}
  end

  def filters
    Filter.for_area(controller_name).in_name_order
  end

  def delete_filter
    @filter.destroy rescue nil
    clear_session_filter
    index
  end

  def reset_filter
    clear_session_filter
    index
  end

  private

  def clear_session_filter
    @filter = Filter.new(area: self.controller_name)
    session[:filter][self.controller_name] = {}
  end

end
