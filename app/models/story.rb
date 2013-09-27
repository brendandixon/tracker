# == Schema Information
#
# Table name: stories
#
#  id           :integer          not null, primary key
#  release_date :datetime
#  title        :string(255)
#  feature_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  date_status  :string(255)      default("planned")
#

class Story < ActiveRecord::Base
  include CacheCleanser
  include StatusScopes

  DATE_STATES = ['planned', 'estimated', 'unknown']

  attr_accessor :create_tasks
  attr_accessible :create_tasks, :references, :references_attributes, :release_date, :release_date_status, :feature_id, :tag_list, :title

  acts_as_taggable

  after_initialize :initialize_create_tasks
  before_validation :ensure_release_date_status
  after_save :ensure_tasks
  
  belongs_to :feature
  has_many :tasks, dependent: :destroy
  has_many :projects, through: :tasks
  has_many :referent_references, as: :referent, dependent: :destroy
  has_many :references, through: :referent_references

  accepts_nested_attributes_for :references, allow_destroy: true
  
  validates_presence_of :feature, :title
  validates_inclusion_of :release_date_status, in: DATE_STATES

  scope :has_tasks_in_state, lambda{|status| where('(SELECT COUNT(*) FROM tasks WHERE tasks.story_id = stories.id AND tasks.status IN (?)) > 0', status)}
  scope :has_tasks_in_state_for_projects, lambda{|status, projects| where('(SELECT COUNT(*) FROM tasks WHERE tasks.story_id = stories.id AND tasks.status IN (?) AND tasks.project_id IN (?)) > 0', status, projects)}

  scope :for_features, lambda{|features| where(feature_id: features)}
  scope :for_projects, lambda{|projects| joins(:tasks).where(tasks: {project_id: projects})}
  
  scope :on_or_after_date, lambda{|date| where('release_date >= ?', date)}
  scope :on_or_before_date, lambda{|date| where('release_date <= ?', date)}
  scope :on_date, lambda{|date| where('release_date = ?', date)}
  
  scope :in_date_order, lambda{|dir = 'ASC'| order("release_date #{dir}")}
  scope :in_feature_order, lambda{|dir = 'ASC'| joins(:feature).order("features.name #{dir}")}
  scope :in_reference_order, lambda{|dir = 'ASC'| order("CAST(references.value AS UNSIGNED) #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("stories.title #{dir}")}
  
  class<<self
    def all_date_states
      @all_states ||= Story::DATE_STATES.map{|s| [s.humanize, s]}
    end

    def all_stories
      @all_stories ||= [['-', '']] + Story.in_title_order.map{|s| [ s.to_s, s.id ] }
    end
    
    def refresh_cache
      @all_stories = nil
    end
  end

  def to_s
    s = self.title
    s += " (#{self.feature.name})" if self.feature.present?
    s += " - #{self.release_date.to_date.to_s(:yy_mm_dd)}" if self.release_date.present?
    s
  end
  
  private
  
  def initialize_create_tasks
    self.create_tasks ||= true
  end

  def ensure_release_date_status
    self.release_date_status = 'planned' if self.release_date_status.nil? && self.release_date.present?
  end
  
  def ensure_tasks
    return unless self.create_tasks
    Task.ensure_story_tasks(self)
  end
  
end
