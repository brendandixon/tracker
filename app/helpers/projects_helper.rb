module ProjectsHelper
  
  def service_labels(services = [])
    services = services.map{|s| s.id}
    Service.active.map do |service|
      classes = 'status label radius'
      classes << ' secondary' unless services.include?(service.id)
      content_tag('span', service.abbreviation, class: classes)
    end.join.html_safe
  end
  
end
