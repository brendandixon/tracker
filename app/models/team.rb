# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  velocity   :integer
#  iteration  :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Team < ActiveRecord::Base

  ITERATION_MAX = 4
  ITERATION_MIN = 1
  
  VELOCITY_MAX = Constants::INTEGER_MAX
  VELOCITY_MIN = 1
  
  attr_accessible :iteration, :name, :projects, :velocity

  has_many :projects
  has_many :tasks, through: :projects

  validates_presence_of :name
  validates_numericality_of :velocity, greater_than_or_equal_to: VELOCITY_MIN, only_integer: true, allow_blank: true
  validates_numericality_of :iteration, greater_than_or_equal_to: ITERATION_MIN, only_integer: true, allow_blank: true

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}
  scope :in_iteration_order, lambda{|dir = 'ASC'| order("iteration #{dir}")}
  scope :in_velocity_order, lambda{|dir = 'ASC'| order("velocity #{dir}")}

  class<<self
    def all_teams
      [['-', '']] + iteration_teams
    end

    def iteration_teams
      Team.in_name_order.all.map{|team| [team.name, team.id]}.uniq
    end
  end

  def iteration_tasks(for_iteration = 0, number_of_iterations = nil)
    iteration = Iteration.new(self, for_iteration)

    tasks = self.tasks.in_rank_order.started_on_or_after(iteration.start_date).to_enum

    Enumerator.new do |yielder|
      task = tasks.next rescue nil
      
      while (number_of_iterations.present? && number_of_iterations > 0) || task.present? do
        task = (tasks.next rescue nil) while task.present? && iteration.consume_task?(task)
        iteration.tasks.each {|task| yielder.yield task, iteration }
        iteration.advance!
        number_of_iterations -= 1 if number_of_iterations.present?
      end

    end
  end

end
