# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :integer
#  start_date :datetime
#  end_date   :datetime
#

class Project < ActiveRecord::Base
  attr_accessible :end_date, :name, :services, :start_date
  
  after_save :refresh_active

  belongs_to :team

  has_many :supported_services, dependent: :destroy
  has_many :services, through: :supported_services

  has_many :tasks, dependent: :destroy
  has_many :stories, through: :tasks

  before_validation :ensure_start_date
  
  validates_presence_of :name
  validates_presence_of :start_date
  
  scope :with_name, lambda {|name| where(name: name) }

  scope :started_on_or_before, lambda{|date| where("projects.start_date <= ?", date)}

  scope :for_services, lambda{|*services| joins(:supported_services).where("? = (select count(*) from supported_services as ss where ss.service_id in (?) and ss.project_id = projects.id)", services.length, services).uniq }
  scope :for_team, lambda{|team| where(team_id: (team.is_a?(Team) ? team.id : team))}

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}

  class<<self
    def active
      @active ||= self.in_name_order.all
    end

    def all_projects
      @all_projects ||= [['-', '']] + Project.active.map{|project| [project.name, project.name]}.uniq
    end
    
    def refresh_active
      @active = nil
      @all_projects = nil
    end
  end

  private

  def ensure_start_date
    self.start_date ||= DateTime.parse('2012-12-01')
  end
  
  def refresh_active
    self.class.refresh_active
  end

end
