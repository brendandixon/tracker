# == Schema Information
#
# Table name: stories
#
#  id         :integer          not null, primary key
#  feature_id :integer
#  project_id :integer
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Story < ActiveRecord::Base
  include FieldExtensions

  INCOMPLETE = [:unscheduled, :scheduled, :in_progress]
  COMPLETED = [:completed]
  STATUS = INCOMPLETE + COMPLETED

  attr_accessible :feature_id, :project_id, :status
    
  belongs_to :feature
  belongs_to :project
  
  symbolize :status
  
  validates_uniqueness_of :feature_id, scope: :project_id
  validates_inclusion_of :status, in: STATUS
  
  scope :for_features, lambda {|features| where(feature_id: features)}
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_services, lambda{|services| joins(:feature).where(features: {service_id: services})}

  scope :in_status, lambda{|status| where(status: status)}
  scope :completed, where(status: Story::COMPLETED)
  scope :incomplete, where(status: Story::INCOMPLETE)

  scope :in_feature_order, lambda{|dir = 'ASC'| joins(:feature).order("features.title #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| joins(:project).order("projects.name #{dir}")}
  scope :in_service_order, lambda{|dir = 'ASC'| joins(feature: :service).order("services.abbreviation #{dir}")}
  scope :in_status_order, lambda{|dir = 'ASC'| order("status #{dir}")}
  
  STATUS.each do |s|
    class_eval <<-EOM
      def #{s}?
        self.status == :#{s}
      end
      def #{s}!
        self.status = :#{s}
        self.save unless self.new_record?
      end
    EOM
  end
  
  class<<self
    
    def ensure_feature_stories(f)
      f.service.projects.each do |project|
        Story.create(feature_id:f.id, project_id:project.id, status: :unscheduled) unless Story.for_features(f).for_projects(project).first
      end
    end

  end
  
  def advance!
    return if self.completed?
    self.status = self.next_status
    self.save unless self.new_record?
  end
  
  def next_status
    STATUS[STATUS.find_index(self.status)+1]
  end
  
end
