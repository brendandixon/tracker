# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  story_id       :integer
#  project_id     :integer
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  title          :string(255)
#  rank           :float
#  points         :integer          default(0)
#  description    :text
#  start_date     :datetime
#  completed_date :datetime
#

class Task < ActiveRecord::Base
  include FieldExtensions

  RANK_MINIMUM = Float::MIN
  RANK_MAXIMUM = Float::MAX

  POINTS_MAXIMUM = 5
  POINTS_MINIMUM = 0

  COMPLETED = [:completed]
  INCOMPLETE = [:pending, :in_progress]
  STARTED = [:completed, :in_progress]
  LEGAL_STATES = INCOMPLETE + COMPLETED
  ALL_STATES = [:iteration, :complete, :incomplete] + INCOMPLETE + COMPLETED

  attr_accessible :completed_date, :description, :points, :project_id, :start_date, :status, :story_id, :title
    
  belongs_to :story
  belongs_to :project
  has_many :tagged_items, as: :taggable
  has_many :tags, through: :tagged_items
  has_many :teams, through: :project
  
  symbolize :status

  after_initialize :ensure_initial
  before_save :ensure_rank  
  before_validation :ensure_dates
  before_validation :ensure_title

  validate :has_title_or_story
  validates_numericality_of :points, only_integer: true, greater_than_or_equal_to: POINTS_MINIMUM, less_than_or_equal_to: POINTS_MAXIMUM, allow_blank: true
  validates_presence_of :project
  validates_inclusion_of :status, in: LEGAL_STATES
  
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_services, lambda{|services| joins(:story).where(stories: {service_id: services})}
  scope :for_stories, lambda {|stories| where(story_id: stories)}
  scope :for_teams, lambda{|teams| joins(:project).where('projects.team_id IN (?)', teams)}

  scope :started_on_or_after, lambda{|date| where("(tasks.status = ? AND tasks.start_date >= ?) OR tasks.status <> ?", :completed, date, :completed)}

  scope :in_state, lambda{|status| where(status: status)}
  scope :completed, where(status: Task::COMPLETED)
  scope :incomplete, where(status: Task::INCOMPLETE)
  scope :started, where(status: Task::STARTED)
  scope :in_progress, where(status: :in_progress)
  scope :pending, where(status: :pending)

  scope :at_least_points, lambda{|points| where("points >= ?", points)}
  scope :no_more_points, lambda{|points| where("points <= ?", points)}

  scope :after_rank, lambda{|rank| where("rank > ?", rank)}
  scope :before_rank, lambda{|rank| where("rank < ?", rank)}
  scope :only_rank, select(:rank)

  scope :in_rank_order, lambda{|dir = 'ASC'| order("rank #{dir}")}
  scope :in_story_order, lambda{|dir = 'ASC'| joins(:story).order("stories.title #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| joins(:project).order("projects.name #{dir}")}
  scope :in_abbreviation_order, lambda{|dir = 'ASC'| joins(story: :service).order("services.abbreviation #{dir}")}
  scope :in_status_order, lambda{|dir = 'ASC'| order("status #{dir}")}
  
  LEGAL_STATES.each do |s|
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

    def all_points
      @all_points ||= [['-', '']] + (Task::POINTS_MINIMUM..Task::POINTS_MAXIMUM).map{|p| [p, p]}
    end

    def all_states
      @all_states ||= [['-', '']] + ALL_STATES.map{|state| [state.to_s.titleize, state]}
    end

    def compute_rank_between(after, before)
      after = (Task.only_rank.find(after) rescue nil) unless after.blank? || after.is_a?(Task)
      after = after.rank unless after.blank?

      before = (Task.only_rank.find(before) rescue nil) unless before.blank? || before.is_a?(Task)
      before = before.rank unless before.blank?

      return task unless after.present? || before.present?

      if after.blank?
        after = Task.in_rank_order('DESC').before_rank(before).only_rank.limit(1).first
        after = after.present? ? after.rank : (before > RANK_MINIMUM+1 ? before - 1 : RANK_MINIMUM)
      elsif before.blank?
        before = Task.in_rank_order.after_rank(after).only_rank.limit(1).first
        before = before.present? ? before.rank : (after < RANK_MAXIMUM-1 ? after + 1 : RANK_MAXIMUM)
      end

      after + ((before - after) / 2.0)
    end
    
    def ensure_story_tasks(story)
      story.service.projects.each do |project|
        next if Task.for_stories(story).for_projects(project).exists?
        Task.create(story_id:story.id, project_id:project.id, status: :pending)
      end
    end

    def set_rank_between(task, after, before)
      task = task.is_a?(Task) ? task : (Task.find(task) rescue nil)
      task.update_attribute(:rank, compute_rank_between(after, before)) if task.present?
      task
    end

  end
  
  def advance!
    return if self.completed?
    self.status = self.next_status
    self.save unless self.new_record?
  end
  
  def next_status
    LEGAL_STATES[LEGAL_STATES.find_index(self.status)+1] || LEGAL_STATES.last
  end
  
  def title
    read_attribute(:title) || (self.story.present? && self.story.title) || nil
  end

  def ensure_rank
    task_after = nil
    task_before = nil

    if self.completed?
      task_before = Task.in_rank_order.incomplete.only_rank.limit(1).first
      task_before = nil if task_before.present? && self.rank.present? && self.rank < task_before.rank
    elsif self.in_progress?
      task_before = Task.in_rank_order.pending.only_rank.limit(1).first
      task_before = nil if task_before.present? && self.rank.present? && self.rank < task_before.rank
    elsif self.pending?
      task_after = Task.in_rank_order('DESC').started.only_rank.limit(1).first
      task_after = nil if task_after.present? && self.rank.present? && self.rank > task_after.rank
    end

    if task_after.present? || task_before.present?
      self.rank = Task.compute_rank_between(task_after, task_before)
    elsif self.rank.blank?
      self.rank = Task.count > 0 ? Task.in_rank_order(self.started? ? 'DESC' : 'ASC').only_rank.limit(1).first.rank : 1
    end
  end

  def set_rank_between(after, before)
    Task.set_rank_between(self, after, before)
  end

  def started?
    STARTED.include?(self.status)
  end

  private

  def ensure_dates
    now = DateTime.now.utc
    if self.pending?
      self.start_date = nil
      self.completed_date = nil
    elsif self.in_progress?
      self.start_date = now if self.start_date.blank?
      self.completed_date = nil
    elsif self.completed?
      self.start_date = now if self.start_date.blank?
      self.completed_date = now if self.completed_date.blank?
    end
  end

  def ensure_initial
    if self.new_record?
      self.points ||= 0
      self.status ||= :pending
    end
  end

  def ensure_title
    write_attribute(:title, nil) if read_attribute(:title).blank?
  end
  
  def has_title_or_story
    if self.title.blank? && self.story.blank?
      self.errors.add(:story, :title_or_story_required)
      self.errors.add(:title, :title_or_story_required)
    end
  end
  
end
