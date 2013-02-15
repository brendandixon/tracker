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
  include CacheCleanser
  
  attr_accessible :end_date, :name, :features, :feature_projects, :feature_projects_attributes, :start_date

  belongs_to :team

  has_many :feature_projects, dependent: :destroy
  has_many :features, through: :feature_projects

  has_many :tasks, dependent: :destroy
  has_many :stories, through: :tasks

  accepts_nested_attributes_for :feature_projects, allow_destroy: true

  after_create :ensure_features
  before_validation :ensure_start_date
  
  validates_presence_of :name
  validates_presence_of :start_date
  
  scope :with_name, lambda {|name| where(name: name) }

  scope :supported, lambda{where('projects.start_date <= :date AND (projects.end_date IS NULL OR projects.end_date > :date)', date: Time.now)}
  scope :started_on_or_before, lambda{|date| where("projects.start_date <= ?", date)}

  scope :for_features, lambda{|*features| joins(:feature_projects).where("? = (select count(*) from feature_projects as fp where fp.feature_id in (?) and fp.project_id = projects.id and fp.status <> 'unsupported')", features.length, features).uniq }
  scope :for_team, lambda{|team| where(team_id: (team.is_a?(Team) ? team.id : team))}

  scope :in_name_order, lambda{|dir = 'ASC'| order("projects.name #{dir}")}

  class<<self
    def active
      @active ||= self.in_name_order.all
    end

    def all_projects
      @all_projects ||= [['-', '']] + Project.active.map{|project| [project.name, project.id]}.uniq
    end
    
    def refresh_cache
      @active = nil
      @all_projects = nil
    end
  end

  def is_feature?(status, feature)
    feature_project = self.feature_projects.for_feature(feature).first
    (status == 'unsupported' && feature_project.blank?) || (feature_project.present? && feature_project.in_state?(status))
  end

  private

  def ensure_features
    FeatureProject.ensure_project_features(self)
  end

  def ensure_start_date
    self.start_date ||= DateTime.parse('2012-12-01')
  end

end
