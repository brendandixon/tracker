class IterationEnumerator
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def each(initial_iteration = 0)
    if block_given?
      self.each_iteration do |iteration|
        iteration.tasks.each {|task| yield task}
      end
    else
      Enumerator.new(self, :each, initial_iteration)
    end
  end

  def each_iteration(initial_iteration = 0)
    if block_given?
      iteration = Iteration.new(@team, number: [0, initial_iteration].min)
      
      @team.tasks.for_iteration(iteration.start_date).each do |task|
        
        until iteration.wants_task?(task)
          yield iteration if iteration.number >= initial_iteration
          iteration = Iteration.new(iteration)
        end

        iteration.add_task(task)
      end
      yield iteration if iteration.number >= initial_iteration
    else
      Enumerator.new(self, :each_iteration, initial_iteration)
    end
  end

end
