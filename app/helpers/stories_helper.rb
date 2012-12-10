module StoriesHelper
  
  def project_labels(s)
    projects = Project.active.map do |project|
            next unless session[:filter][:projects].blank? || session[:filter][:projects].include?(project.name)
            task = s.tasks.detect{|task| task.project == project ? task : nil}
            status = if task.unscheduled?
                      ' has-tip alert'
                     elsif task.completed?
                      ' has-tip success'
                     else
                      ' has-tip'
                     end if task.present?
            options = {
              class: 'label radius' + (status.present? ? status : ' secondary')
            }
            options[:title] = I18n.t(task.status, scope: [:activerecord, :labels, :task]) if task.present?
            content_tag('span', project.name, options)
          end.join.html_safe
    link_to projects, tasks_path(stories: s.id, projects: session[:filter][:projects], status: :all), class: 'projects'
  end
  
end
