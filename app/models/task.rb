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
#  title      :string(255)
#  rank       :float
#

class Task < ActiveRecord::Base
  include FieldExtensions

  RANK_MINIMUM = Float::MIN
  RANK_MAXIMUM = Float::MAX

  INCOMPLETE = [:pending, :in_progress]
  COMPLETED = [:completed]
  STATUS = INCOMPLETE + COMPLETED
  STATES = [:all, :complete, :incomplete]

  attr_accessible :story_id, :project_id, :status
    
  belongs_to :story
  belongs_to :project
  has_many :tagged_items, as: :taggable
  has_many :tags, through: :tagged_items
  
  symbolize :status
  
  before_validation :normalize_title

  validate :has_title_or_story
  validates_uniqueness_of :story_id, scope: :project_id, allow_blank: true
  validates_inclusion_of :status, in: STATUS
  
  scope :for_stories, lambda {|stories| where(story_id: stories)}
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_services, lambda{|services| joins(:story).where(stories: {service_id: services})}

  scope :in_status, lambda{|status| where(status: status)}
  scope :completed, where(status: Task::COMPLETED)
  scope :incomplete, where(status: Task::INCOMPLETE)

  scope :in_rank_order, lambda{|dir = 'ASC'| order("rank #{dir}")}
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

    def all_states
      STATES.map{|state| [state.to_s.titleize, state]}
    end
    
    def ensure_story_tasks(f)
      f.service.projects.each do |project|
        Task.create(story_id:f.id, project_id:project.id, status: :pending) unless Task.for_stories(f).for_projects(project).first
      end
    end

    def rank_between(task, before, after)
      task = task.is_a?(Task) ? task : Task.find(task)
      before = before.present? ? (before.is_a?(Task) ? before : Task.select(:rank).find(before)).rank : RANK_MAXIMUM
      after = after.present? ? (after.is_a?(Task) ? after : Task.select(:rank).find(after)).rank : RANK_MINIMUM

      task.update_attribute(:rank, after + ((before - after) / 2))
      task
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
  
  def title
    self.story.present? ? self.story.title : read_attribute(:title)
  end
  
  def title=(s)
    write_attribute(:title, s) unless story.present?
  end

  def rank_between(before, after)
    Task.rank_between(self, before, after)
  end

  private
  
  def has_title_or_story
    if self.title.blank? && self.story.blank?
      self.errors.add(:story, :title_or_story_required)
      self.errors.add(:title, :title_or_story_required)
    end
  end
  
  def normalize_title
    write_attribute(:title, nil) if story.present? && read_attribute(:title)
  end
  
end
