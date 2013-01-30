module TeamsHelper
  
  def team_project_labels(projects = [])
    Project.active.map do |project|
      classes = 'label'
      classes << ' label-info' if projects.include?(project)
      content_tag('span', project.name, class: classes)
    end.join.html_safe
  end
  
end
