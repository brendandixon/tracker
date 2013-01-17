module ProjectsHelper
  
  def feature_labels(features = [])
    features = features.map{|s| s.id}
    Feature.active.map do |feature|
      classes = 'status label radius'
      classes << ' secondary' unless features.include?(feature.id)
      content_tag('span', feature.name, class: classes)
    end.join.html_safe
  end
  
end
