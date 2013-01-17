# == Schema Information
#
# Table name: stories
#
#  id                :integer          not null, primary key
#  release_date      :datetime
#  title             :string(255)
#  feature_id        :integer
#  contact_us_number :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Story < ActiveRecord::Base
  include CacheCleanser
  include StatusScopes

  attr_accessor :create_tasks
  attr_accessible :contact_us_number, :create_tasks, :release_date, :feature_id, :title

  after_initialize :initialize_create_tasks
  after_save :ensure_tasks
  
  belongs_to :feature
  has_many :tasks, dependent: :destroy
  has_many :projects, through: :tasks
  
  validates_presence_of :feature, :title
  validates_numericality_of :contact_us_number, only_integer: true, greater_than: 0, allow_nil: true

  scope :for_contact_us, lambda{|cu| where(contact_us_number: cu)}
  scope :for_features, lambda{|features| where(feature_id: features)}
  scope :for_projects, lambda{|projects| joins(:tasks).where(tasks: {project_id: projects})}
  
  scope :on_or_after_date, lambda{|date| where('release_date >= ?', date)}
  scope :on_or_before_date, lambda{|date| where('release_date <= ?', date)}
  scope :on_date, lambda{|date| where('release_date = ?', date)}
  
  scope :in_contact_us_order, lambda{|dir = 'ASC'| order("contact_us_number #{dir}")}
  scope :in_date_order, lambda{|dir = 'ASC'| order("release_date #{dir}")}
  scope :in_feature_order, lambda{|dir = 'ASC'| joins(:feature).order("features.name #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("title #{dir}")}
  
  class<<self
    def all_stories
      @all_stories ||= [['-', '']] + Story.in_title_order.map{|s| [ "#{s.title} (#{s.feature.name})", s.id ] }
    end
    
    def refresh_cache
      @all_stories = nil
    end
  end

  def contact_us_link
    return nil unless self.contact_us_number.present?
    "https://contactus.amazon.com/contact-us/ContactUsIssue.cgi?issue=#{self.contact_us_number}&profile=aws-dr-tools"
  end
  
  private
  
  def initialize_create_tasks
    self.create_tasks ||= true
  end
  
  def ensure_tasks
    return unless self.create_tasks
    Task.ensure_story_tasks(self)
  end
  
end
