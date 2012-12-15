# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  project_id :integer
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Task < ActiveRecord::Base
  include FieldExtensions

  INCOMPLETE = [:unscheduled, :scheduled, :in_progress]
  COMPLETED = [:completed]
  STATUS = INCOMPLETE + COMPLETED

  attr_accessible :story_id, :project_id, :status
    
  belongs_to :story
  belongs_to :project
  has_many :tagged_items, as: :taggable
  has_many :tags, through: :tagged_items
  
  symbolize :status
  
  validates_uniqueness_of :story_id, scope: :project_id
  validates_inclusion_of :status, in: STATUS
  
  scope :for_stories, lambda {|stories| where(story_id: stories)}
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_services, lambda{|services| joins(:stories).where(stories: {service_id: services})}

  scope :in_status, lambda{|status| where(status: status)}
  scope :completed, where(status: Task::COMPLETED)
  scope :incomplete, where(status: Task::INCOMPLETE)

  scope :in_story_order, lambda{|dir = 'ASC'| joins(:story).order("stories.title #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| joins(:project).order("projects.name #{dir}")}
  scope :in_service_order, lambda{|dir = 'ASC'| joins(story: :service).order("services.abbreviation #{dir}")}
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
    
    def ensure_story_tasks(f)
      f.service.projects.each do |project|
        Task.create(story_id:f.id, project_id:project.id, status: :unscheduled) unless Task.for_stories(f).for_projects(project).first
      end
    end

  end
  
  def advance!
    return if self.completed?
    self.status = self.next_status
    self.save unless self.new_record?
  end
  
  def next_status
    STATUS[STATUS.find_index(self.status)+1] || STATUS.last
  end
  
end
