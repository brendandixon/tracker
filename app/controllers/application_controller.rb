class ApplicationController < ActionController::Base
  DEFAULT_SORT = []
  
  protect_from_forgery
  
  before_filter :initialize_filter, only: :index
  before_filter :initialize_sort, only: :index
  
  def initialize_filter
    session[:filter] ||= {}
    session[:filter][self.controller_name] = params[:filter] if params[:filter]
    session[:filter][self.controller_name] ||= {}

    attributes = session[:filter][self.controller_name]

    @filter = (Filter.for_area(self.controller_name).find(attributes[:id]) rescue nil) if attributes[:id].present?
    @filter ||= Filter.new(area: self.controller_name)
    @filter.attributes = attributes.reject{|k,v| [:id].include?(k)} if attributes.is_a?(Hash) && !attributes.empty?

    normalize_filter

    @filter.save if @filter.present? && params[:commit]
  end

  def initialize_sort
    session[:sort] ||= {}
    
    @sort = params[:sort] || session[:sort][self.controller_name] || self.class::DEFAULT_SORT
    @sort = @sort.split(',').map{|s| s.downcase} if @sort.is_a?(String)
    descending = @sort.map{|s| s =~ /^\-\w+$/ ? true : false}
    @sort = @sort.map{|s| s =~ /^-(\w+)$/ ? $1 : s}.reverse.uniq.reverse
    @sort.each_with_index{|s, i| @sort[i] = "-#{s}" if descending[i]}

    session[:sort][self.controller_name] = @sort
  end

  def normalize_filter
    @filter.content ||= {}
    content = @filter.content
    
    content[:after] = params[:after] || content[:after]
    content[:before] = params[:before] || content[:before]

    content[:contact_us] = params[:contact_us] || content[:contact_us]
    content[:contact_us] = content[:contact_us].split(',') if content[:contact_us].is_a?(String)

    content[:projects] = params[:projects] || content[:projects]
    content[:projects] = content[:projects].split(',') if content[:projects].is_a?(String)

    content[:services] = params[:services] || content[:services]
    content[:services] = content[:services].split(',') if content[:services].is_a?(String)

    content[:status] = params[:status] || content[:status] || :incomplete
    content[:status] = content[:status].downcase.to_sym if content[:status].is_a?(String)
  end

  def filters
    Filter.for_area(controller_name)
  end

  def reset
    session[:filter][self.controller_name] = {}
    redirect_to controller: self.controller_name, action: :index, show: params[:show]
  end

end
