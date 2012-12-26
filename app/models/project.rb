# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Project < ActiveRecord::Base

  attr_accessible :name, :services

  has_many :supported_services, dependent: :destroy
  has_many :services, through: :supported_services

  has_many :tasks, dependent: :destroy
  has_many :stories, through: :tasks
  
  validates_presence_of :name
  
  scope :with_name, lambda {|name| where(name: name) }
  
  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}

  class<<self
    def active
      @active ||= self.in_name_order.all
    end

    def all_projects
      @all_projects ||= [['Any Project', '']] + Project.active.map{|project| [project.name, project.name]}.uniq
    end
  end

end
