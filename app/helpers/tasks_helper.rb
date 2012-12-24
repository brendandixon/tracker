module TasksHelper
  
  def task_status_tag(task, project = nil)
    status = if task.blank?
              ' secondary'
             elsif task.pending?
              ' alert'
             elsif task.completed?
              ' success'
             else
              ''
             end
    options = {
      class: 'status label radius' << status
    }
    content_tag('span', (project.present? ? project.name : I18n.t(task.status, scope: [:activerecord, :labels, :task])), options)
  end

end
