# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  velocity    :integer
#  sprint_days :integer          default(7)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
    (start_date + ((DateTime.now.beginning_of_week.utc - start_date).to_i / 7 / self.iteration * self.iteration).weeks).beginning_of_week
  end

  def iteration_end_date(start_date = iteration_start_date)
    start_date.beginning_of_week + self.iteration.weeks - 1.day
  end

  def iteration_tasks(all_tasks = nil)
    points = 0
    all_tasks ||= self.tasks.in_rank_order.in_status_order('DESC').started_on_or_after(iteration_start_date)
    all_tasks.inject([]) do |tasks, task|
      break tasks if task.pending? && points >= self.velocity
      points += task.points
      tasks << task
      tasks
    end
  end

end
