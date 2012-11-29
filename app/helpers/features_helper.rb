module FeaturesHelper
  
  def project_labels(f)
    projects = Project.active.map do |project|
            next unless session[:filter][:projects].blank? || session[:filter][:projects].include?(project.name)
            story = f.stories.detect{|story| story.project == project ? story : nil}
            status = if story.unscheduled?
                      ' has-tip alert'
                     elsif story.completed?
                      ' has-tip success'
                     else
                      ' has-tip'
                     end if story.present?
            options = {
              class: 'label radius' + (status.present? ? status : ' secondary')
            }
            options[:title] = I18n.t(story.status, scope: [:activerecord, :labels, :story]) if story.present?
            content_tag('span', project.name, options)
          end.join.html_safe
    link_to projects, stories_path(features: f.id, projects: session[:filter][:projects], status: :all), class: 'projects'
  end
  
end
