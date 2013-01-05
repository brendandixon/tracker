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
  
  VELOCITY_MAX = (2**(0.size * 8 -2) -1)
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
      [['-', '']] + Team.in_name_order.all.map{|team| [team.name, team.id]}.uniq
    end
  end

  def iteration_start_date
    return DateTime.now.beginning_of_week.utc if self.projects.blank?
    start_date = self.projects.map{|p| p.start_date}.compact.min
    return DateTime.now.beginning_of_week.utc if start_date.blank?
    start_date = start_date.to_datetime unless start_date.is_a?(DateTime)
    days_since_start = (DateTime.now.beginning_of_week.utc - start_date.beginning_of_week.utc).to_i
    iterations_since_start = (days_since_start + (self.iteration * 7) - 1) / (self.iteration * 7)
    (start_date + (iterations_since_start * self.iteration).weeks).beginning_of_week
  end

  def iteration_end_date(start_date = iteration_start_date)
    start_date.beginning_of_week + self.iteration.weeks - 1.day
  end

  def iteration_tasks(start_date = iteration_start_date)
    all_tasks = self.tasks.in_rank_order.in_status_order('DESC').started_on_or_after(iteration_start_date)
    tasks = []
    iteration_enum(all_tasks).each do |task, iteration = nil, points = nil, end_date = nil|
      next if start_date > end_date
      break if task.blank?
      tasks << task
    end
    tasks
  end

  def iteration_enum(tasks = [])
    current_iteration = 0
    end_date = iteration_end_date
    velocity_remaining = self.velocity
    Enumerator.new do |yielder|
      tasks.each do |task|
        if velocity_remaining <= 0 && task.pending?
          yielder.yield nil, current_iteration, self.velocity - velocity_remaining, end_date
          current_iteration += 1
          end_date = iteration_end_date(end_date + 1.day)
          velocity_remaining = self.velocity
        end
        yielder.yield task, current_iteration, self.velocity - velocity_remaining, end_date
        velocity_remaining -= task.points
      end
      yielder.yield nil, current_iteration, self.velocity - velocity_remaining, end_date
    end
  end

end
