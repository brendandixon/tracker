class Team < ActiveRecord::Base
  attr_accessible :name, :sprint_days, :velocity

  has_many :projects

  validates_presence_of :name
  validates_numericality_of :velocity, only_integer: true, allow_blank: true
  validates_numericality_of :sprint_days, only_integer: true, allow_blank: true

end
