module TasksHelper

  def points_to_class(points)
    case points
    when 0, nil then 'zero-points'
    when 1 then 'one-point'
    when 2 then 'two-points'
    when 3 then 'three-points'
    when 4 then 'four-points'
    when 5 then 'five-points'
    end
  end
  
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

  def title_options(task)
    return {} unless task.description.present?
    options = {
      class: 'has-tip',
      title: task.description
    }
    options[:data] = {width: '350px'} if task.description.length > (350 / 7)
    options
end

end
