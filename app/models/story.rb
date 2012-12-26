# == Schema Information
#
# Table name: stories
#
#  id                :integer          not null, primary key
#  release_date      :datetime
#  title             :string(255)
#  service_id        :integer
#  contact_us_number :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Story < ActiveRecord::Base
  # include Validations

  attr_accessor :create_tasks
  attr_accessible :contact_us_number, :create_tasks, :release_date, :service_id, :title

  after_initialize :initialize_create_tasks
  after_save :ensure_tasks
  
  belongs_to :service
  has_many :tasks, dependent: :destroy
  has_many :projects, through: :tasks
  has_many :tagged_items, as: :taggable
  has_many :tags, through: :tagged_items
  
  before_validation :ensure_release_date
  
  validates_presence_of :service, :title
  validates_numericality_of :contact_us_number, only_integer: true, greater_than: 0, allow_nil: true
  # validates_date_of :release_date, allow_nil: true

  scope :in_status, lambda{|status| joins(:tasks).where(tasks: {status: status})}
  scope :completed, joins(:tasks).where(tasks: {status: Task::COMPLETED})
  scope :incomplete, joins(:tasks).where(tasks: {status: Task::INCOMPLETE})
  
  scope :for_projects, lambda{|projects| joins(:tasks).where(tasks: {project_id: projects})}
  scope :for_services, lambda{|services| where(service_id: services)}
  scope :for_contact_us, lambda{|cu| where(contact_us_number: cu)}
  
  scope :on_or_after_date, lambda{|date| where('release_date >= ?', date)}
  scope :on_or_before_date, lambda{|date| where('release_date <= ?', date)}
  scope :on_date, lambda{|date| where('release_date = ?', date)}
  
  scope :in_contact_us_order, lambda{|dir = 'ASC'| order("contact_us_number #{dir}")}
  scope :in_date_order, lambda{|dir = 'ASC'| order("release_date #{dir}")}
  scope :in_service_order, lambda{|dir = 'ASC'| joins(:service).order("services.abbreviation #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("title #{dir}")}
  
  class<<self
    def all_stories
      [['Any Story', '']] + Story.in_title_order.map{|s| [ "#{s.title} (#{s.service.abbreviation})", s.id ] }
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
  
  def ensure_release_date
    return unless self.release_date.present?
    self.release_date = ActiveSupport::TimeZone.new(Tracker::Application.config.time_zone).parse(self.release_date) if self.release_date.is_a?(String)
    self.release_date = self.release_date.to_datetime if self.release_date.is_a?(Date)
    self.release_date = self.release_date.utc if self.release_date.is_a?(DateTime)
  end
  
end
