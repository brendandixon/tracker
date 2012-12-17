module StoriesHelper
  
  def project_labels(story)
    projects = Project.active.map do |project|
            next unless session[:filter][:projects].blank? || session[:filter][:projects].include?(project.name)
            task = story.tasks.detect{|task| task.project == project ? task : nil}
            task_status_tag(task, project)
          end.join.html_safe
    link_to projects, tasks_path(stories: story.id, projects: session[:filter][:projects], status: :all), class: 'projects'
  end
  
end
