class ApplicationController < ActionController::Base
  DEFAULT_SORT = []
  
  protect_from_forgery
  
  before_filter :normalize_filter_parameters, only: :index
  
  def normalize_filter_parameters
    session[:filter] ||= {}
    @filter = session[:filter]

    @filter[:after] = params[:after] || @filter[:after]
    @filter[:before] = params[:before] || @filter[:before]
    
    @filter[:contact_us] = params[:contact_us] || @filter[:contact_us]
    @filter[:contact_us] = @filter[:contact_us].split(',') if @filter[:contact_us].is_a?(String)

    @filter[:projects] = params[:projects] || @filter[:projects]
    @filter[:projects] = @filter[:projects].split(',') if @filter[:projects].is_a?(String)

    @filter[:services] = params[:services] || @filter[:services]
    @filter[:services] = @filter[:services].split(',') if @filter[:services].is_a?(String)

    @filter[:sort] = @filter[:sort] || {}
    sort = params[:sort] || @filter[:sort][self.controller_name] || self.class::DEFAULT_SORT
    sort = sort.split(',').map{|s| s.downcase} if sort.is_a?(String)
    descending = sort.map{|s| s =~ /^\-\w+$/ ? true : false}
    sort = sort.map{|s| s =~ /^-(\w+)$/ ? $1 : s}.reverse.uniq.reverse
    sort.each_with_index{|s, i| sort[i] = "-#{s}" if descending[i]}
    @filter[:sort][self.controller_name] = sort

    @filter[:status] = params[:status] || @filter[:status] || :incomplete
    @filter[:status] = @filter[:status].downcase.to_sym if @filter[:status].is_a?(String)
  end
  
  def reset
    session[:filter] = {}
    redirect_to controller: self.controller_name, action: :index
  end
end
