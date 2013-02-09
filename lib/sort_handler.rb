module SortHandler
  extend ActiveSupport::Concern
  
  DEFAULT_SORT = []
  SORT_FIELDS = []

  included do  
    before_filter :initialize_sort
  end

  def initialize_sort
    session[:sort] ||= {}
    
    @sort = params[:sort] || session[:sort][self.controller_name] || []
    @sort = @sort.split(',').map{|s| s.downcase} if @sort.is_a?(String)
    @sort = sanitize_sort(@sort)
    @sort = self.class::DEFAULT_SORT if @sort.empty?
    
    session[:sort][self.controller_name] = @sort
  end

  def sanitize_sort(sort)
    sorts = {}
    sort.each_with_index do |s, i|
      s =~ /^(-)(\w+)$/
      sorts[$2 || s] = [$1.present?, i]
    end
    sorts.keep_if{|s, a| self.class::SORT_FIELDS.include?(s)}.map{|k, v| ('%04d:' % v.last) + "#{v.first ? '-' : ''}#{k}"}.sort.map{|s| s.split(':').last}
  end

end
