class Iteration
  attr_reader :number, :start_date, :end_date, :next, :points, :previous, :team

  CURRENT_ITERATION = 0
  DEFAULT_START_DATE = '2012-01-01'

  def initialize(*args)
    options = args.extract_options!
    options.symbolize_keys!

    previous = args.first if args.first.is_a?(Iteration)

    @team = previous.team if previous.present?
    @team = args.first if @team.blank?
    raise ArgumentError.new("Team or Iteration required") unless @team.is_a?(Team)

    @weeks = @team.iteration.weeks

    if previous.present?
      @number = previous.number + 1
      @start_date = previous.start_date + @weeks
    else
      @number = options[:number] || 0
  
      start_date = @team.projects.map{|p| p.start_date}.compact.min
      start_date = DateTime.parse(DEFAULT_START_DATE) if start_date.blank?
      start_date = start_date.to_datetime unless start_date.is_a?(DateTime)

      days_since_start = (DateTime.now.beginning_of_week - start_date.beginning_of_week).to_i
      iterations_since_start = (days_since_start + (@team.iteration * 7) - 1) / (@team.iteration * 7)
      iterations_since_start += number
      if iterations_since_start < 0
        number -= iterations_since_start
        iterations_since_start = 0
      end
      
      @start_date = (start_date + (iterations_since_start * @team.iteration).weeks).beginning_of_week
    end

    @end_date = @start_date + @weeks - 1.day
    @points = 0
    @tasks = []
    @velocity = @team.velocity
  end

  def after_current?
    @number > CURRENT_ITERATION
  end

  def before_current?
    @number < CURRENT_ITERATION
  end

  def current?
    @number == CURRENT_ITERATION
  end

  def is?(number)
    @number == number
  end

  def full?
    @points >= @velocity
  end

  def add_task(task)
    @points += task.points
    @tasks << task
  end

  def wants_task?(task)
    (task.completed_during?(@start_date, @end_date) || (current? && task.started?) || (!before_current? && !full?))
  end

  def tasks
    @tasks.clone
  end

end

