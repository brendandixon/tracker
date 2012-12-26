module StoriesHelper
  
  def project_labels(story, only_projects = [])
    projects = Project.active.map do |project|
            next unless only_projects.blank? || only_projects.include?(project.name)
            task = story.tasks.detect{|task| task.project == project ? task : nil}
            task_status_tag(task, project)
          end.join.html_safe
    link_to projects, tasks_path(filter: {content:{status: :all, stories: story.id, projects: only_projects}}), class: 'projects', remote: true
  end
  
end
