class Iteration
  attr_reader :number, :start_date, :end_date, :points, :tasks

  def initialize(team, number = 0)
    @tasks = []
    @team = team
    @velocity = @team.velocity
    @weeks = @team.iteration.weeks

    start_date = @team.projects.map{|p| p.start_date}.compact.min
    start_date = DateTime.parse('2000-01-01') if start_date.blank?
    start_date = start_date.to_datetime unless start_date.is_a?(DateTime)

    days_since_start = (DateTime.now.beginning_of_week - start_date.beginning_of_week).to_i
    iterations_since_start = (days_since_start + (@team.iteration * 7) - 1) / (@team.iteration * 7)
    iterations_since_start += number
    if iterations_since_start < 0
      number -= iterations_since_start
      iterations_since_start = 0
    end
    
    start_date = (start_date + (iterations_since_start * @team.iteration).weeks).beginning_of_week

    @number = number
    @start_date = start_date
    @end_date = start_date + @weeks - 1.day
    @points = 0
  end

  def advance!
    @number += 1
    @start_date += @weeks
    @end_date += @weeks
    @points = 0
    @tasks = []
  end

  def after_current?
    @number > 0
  end

  def before_current?
    @number < 0
  end

  def current?
    @number == 0
  end

  def is?(number)
    @number == number
  end

  def empty?
    @tasks.empty?
  end

  def full?
    @points >= @velocity
  end

  def consume_task?(task = nil)
    if owns_task?(task)
      add_task(task)
      true
    else
      false
    end
  end

  def owns_task?(task = nil)
    task.present? && (task.completed_during?(@start_date, @end_date) || (current? && task.started?) || (!before_current? && !full?))
  end

  private

  def add_task(task)
    @points += task.points
    @tasks << task
  end

end
