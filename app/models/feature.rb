# == Schema Information
#
# Table name: features
#
#  id                :integer          not null, primary key
#  release_date      :datetime
#  title             :string(255)
#  service_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contact_us_number :integer
#

class Feature < ActiveRecord::Base
  # include Validations

  attr_accessor :create_stories
  attr_accessible :contact_us_number, :create_stories, :release_date, :service_id, :title

  after_initialize :initialize_create_stories
  after_save :ensure_stories
  
  belongs_to :service
  has_many :stories, dependent: :destroy
  has_many :projects, through: :stories
  
  before_validation :ensure_release_date
  
  validates_presence_of :service, :title
  validates_numericality_of :contact_us_number, only_integer: true, greater_than: 0, allow_nil: true
  # validates_date_of :release_date, allow_nil: true

  scope :in_status, lambda{|status| joins(:stories).where(stories: {status: status})}
  scope :completed, joins(:stories).where(stories: {status: Story::COMPLETED})
  scope :incomplete, joins(:stories).where(stories: {status: Story::INCOMPLETE})
  
  scope :for_projects, lambda{|projects| joins(:stories).where(stories: {project_id: projects})}
  scope :for_services, lambda{|services| where(service_id: services)}
  scope :for_contact_us, lambda{|cu| where(contact_us_number: cu)}
  
  scope :after_date, lambda{|date| where('release_date > ?', date)}
  scope :before_date, lambda{|date| where('release_date < ?', date)}
  scope :on_date, lambda{|date| where('release_date = ?', date)}
  
  scope :in_date_order, lambda{|dir = 'ASC'| order("release_date #{dir}")}
  scope :in_service_order, lambda{|dir = 'ASC'| joins(:service).order("services.abbreviation #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("title #{dir}")}
  
  def contact_us_link
    return nil unless self.contact_us_number.present?
    "https://contactus.amazon.com/contact-us/ContactUsIssue.cgi?issue=#{self.contact_us_number}&profile=aws-dr-tools"
  end
  
  private
  
  def initialize_create_stories
    self.create_stories ||= true
  end
  
  def ensure_stories
    return unless self.create_stories
    Story.ensure_feature_stories(self)
  end
  
  def ensure_release_date
    return unless self.release_date.present?
    self.release_date = DateTime.parse(self.release_date) if self.release_date.is_a?(String)
    self.release_date = self.release_date.to_datetime if self.release_date.is_a?(Date)
    self.release_date = self.release_date.utc if self.release_date.is_a?(DateTime)
  end
  
end
