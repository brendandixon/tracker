module TasksHelper
  
  def task_status_tag(task, project = nil)
    status = if task.unscheduled?
              ' has-tip alert'
             elsif task.completed?
              ' has-tip success'
             else
              ' has-tip'
             end if task.present?
    options = {
      class: 'status label radius' + (status.present? ? status : ' secondary')
    }
    options[:title] = I18n.t(task.status, scope: [:activerecord, :labels, :task]) if task.present?
    content_tag('span', (project.present? ? project.name : I18n.t(task.status, scope: [:activerecord, :labels, :task])), options)
  end

end
