module ProjectsHelper
  
  def service_labels(services = [])
    Service.active.map do |service|
      classes = 'status label radius'
      classes << ' secondary' unless services.include?(service)
      content_tag('span', service.abbreviation, class: classes)
    end.join.html_safe
  end
  
end
