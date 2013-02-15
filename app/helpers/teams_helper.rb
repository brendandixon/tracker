module TeamsHelper
  
  def team_project_labels(projects = [])
    Project.active.map do |project|
      status_tag project.name, projects.include?(project) ? 'completed' : 'unsupported'
    end.join.html_safe
  end
  
end
