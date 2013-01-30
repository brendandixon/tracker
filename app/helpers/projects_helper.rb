module ProjectsHelper
  
  def feature_labels(features = [])
    features = features.map{|f| f.id}.sort
    Feature.active.map do |feature|
      classes = 'label '
      classes << ' label-info' if features.include?(feature.id)
      content_tag('span', feature.name, class: classes)
    end.join.html_safe
  end
  
end
