module SortHandler
  extend ActiveSupport::Concern
  
  DEFAULT_SORT = []

  included do  
    before_filter :initialize_sort
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

end
