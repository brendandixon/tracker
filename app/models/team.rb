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
  attr_accessible :name, :projects, :sprint_days, :velocity

  has_many :projects

  validates_presence_of :name
  validates_numericality_of :velocity, greater_than: 0, only_integer: true, allow_blank: true
  validates_numericality_of :sprint_days, greater_than: 0, only_integer: true, allow_blank: true

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}
  scope :in_sprint_days_order, lambda{|dir = 'ASC'| order("sprint_days #{dir}")}
  scope :in_velocity_order, lambda{|dir = 'ASC'| order("velocity #{dir}")}

  class<<self
    def all_teams
      [['-', '']] + Team.in_name_order.all.map{|team| [team.name, team.id]}.uniq
    end
  end

end
