module ProjectsHelper
  
  def feature_labels(feature_projects = [])
    feature_projects.map do |feature_project|
      status_tag feature_project.feature.name, feature_project.status
    end.join.html_safe
  end
  
end
