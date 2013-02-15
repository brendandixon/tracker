module StoriesHelper
  
  def story_project_labels(story, only_projects = [])
    projects = Project.active.map do |project|
            next unless only_projects.blank? || only_projects.include?(project.id)
            task = story.tasks.map{|task| task.project_id == project.id ? task : nil}.compact.sort{|task1, task2| task1.status <=> task2.status}.last
            status_tag project.name, (task.present? && task.status) || 'unsupported'
          end.join.html_safe
    link_to projects, tasks_path(filter: {content:{stories: story.id, projects: only_projects}})
  end
  
end
