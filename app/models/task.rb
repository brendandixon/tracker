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
  include StatusScopes

  RANK_MINIMUM = Float::MIN
  RANK_MAXIMUM = Float::MAX

  POINTS_MAXIMUM = 5
  POINTS_MINIMUM = 0

  attr_accessible :completed_date, :description, :points, :project_id, :start_date, :status, :story_id, :title
    
  belongs_to :story
  has_one :service, through: :story
  belongs_to :project
  has_many :teams, through: :project
  
  symbolize :status

  after_initialize :ensure_initial
  before_save :ensure_rank  
  before_validation :ensure_dates
  before_validation :ensure_title

  validate :has_title_or_story
  validates_numericality_of :points, only_integer: true, greater_than_or_equal_to: POINTS_MINIMUM, less_than_or_equal_to: POINTS_MAXIMUM, allow_blank: true
  validates_presence_of :project
  validates_inclusion_of :status, in: ALL_STATES

  default_scope includes(:project, :service)

  scope :for_iteration, lambda{|iteration_start_date| in_rank_order.completed_on_or_after(iteration_start_date).uniq }
  
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_services, lambda{|services| joins(:story).where(stories: {service_id: services})}
  scope :for_stories, lambda {|stories| where(story_id: stories)}
  scope :for_teams, lambda{|teams| joins(:teams).where(teams: {id: teams})}

  scope :completed_on_or_after, lambda{|date| where("(tasks.status = ? AND tasks.completed_date >= ?) OR tasks.status <> ?", :completed, date, :completed)}

  scope :at_least_points, lambda{|points| where("points >= ?", points)}
  scope :no_more_points, lambda{|points| where("points <= ?", points)}

  scope :after_rank, lambda{|rank| where("rank > ?", rank)}
  scope :before_rank, lambda{|rank| where("rank < ?", rank)}
  
  scope :pick_rank, select(:rank)

  scope :in_abbreviation_order, lambda{|dir = 'ASC'| order("services.abbreviation #{dir}")}
  scope :in_point_order, lambda{|dir = 'ASC'| order("points #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| order("projects.name #{dir}")}
  scope :in_rank_order, lambda{|dir = 'ASC'| order("rank #{dir}")}
  scope :in_status_order, lambda{|dir = 'ASC'| order("status #{dir}")}
  scope :in_story_order, lambda{|dir = 'ASC'| order("stories.title #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("tasks.title #{dir}")}
  
  StatusScopes::ALL_STATES.each do |s|
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
      @all_states ||= [['-', '']] + StatusScopes::ALL_STATES.map{|state| [state.to_s.titleize, state]}
    end
    
    def ensure_story_tasks(story)
      story.service.projects.each do |project|
        next if Task.for_stories(story).for_projects(project).exists?
        Task.create(story_id:story.id, project_id:project.id, status: :pending)
      end
    end

  end
  
  def advance!
    return if self.completed?
    self.status = self.next_status
    self.save unless self.new_record?
  end

  def completed_after?(date)
    self.completed? && self.completed_date > date
  end

  def completed_before?(date)
    self.completed? && self.completed_date < date
  end

  def completed_during?(start_date, end_date)
    self.completed? && self.completed_date >= start_date && self.completed_date <= end_date
  end

  def incomplete?
    !self.completed?
  end

  def started?
    StatusScopes::STARTED.include?(self.status)
  end

  def started_after?(date)
    self.started? && self.start_date > date
  end

  def started_before?(date)
    self.started? && self.start_date < date
  end

  def started_during?(start_date, end_date)
    self.started? && self.start_date >= start_date && self.start_date <= end_date
  end
  
  def next_status
    StatusScopes::ALL_STATES[StatusScopes::ALL_STATES.find_index(self.status)+1] || StatusScopes::ALL_STATES.last
  end
  
  def title
    read_attribute(:title) || (self.story.present? && self.story.title) || nil
  end

  def ensure_rank
    after = nil
    before = nil

    query = Task
    query = query.where("tasks.id <> ?", self.id) unless self.new_record?

    if self.completed?
      before = query.in_rank_order.incomplete.pick_rank.limit(1).first
      before = nil if before.present? && self.rank.present? && self.rank < before.rank
    elsif self.in_progress?
      before = query.in_rank_order.pending.pick_rank.limit(1).first
      before = nil if before.present? && self.rank.present? && self.rank < before.rank
    elsif self.pending?
      after = query.in_rank_order('DESC').started.pick_rank.limit(1).first
      after = nil if after.present? && self.rank.present? && self.rank > after.rank
    end

    if after.present? || before.present?
      self.rank_between(after, before)
    elsif self.rank.blank?
      if Task.count <= 0
        self.rank = 1
      else
        after = query.started.in_rank_order('DESC').pick_rank.limit(1).first if self.started?
        before = query.pending.in_rank_order.pick_rank.limit(1).first if after.blank?
        self.rank = after.present? ? after + 1 : before - 1
      end
    end
  end

  def rank_between(after, before)

    query = Task
    query = query.where("tasks.id <> ?", self.id) unless self.new_record?
    
    after = (query.pick_rank.find(after) rescue nil) unless after.blank? || after.is_a?(Task)
    before = (query.pick_rank.find(before) rescue nil) unless before.blank? || before.is_a?(Task)

    return false if after.blank? && before.blank?

    if after.blank?
      after = query.in_rank_order('DESC').before_rank(before).pick_rank.limit(1).first
    elsif before.blank?
      before = query.in_rank_order.after_rank(after).pick_rank.limit(1).first
    end

    after_rank = after.present? ? after.rank : (before.rank > RANK_MINIMUM+1 ? before.rank - 1 : RANK_MINIMUM)
    before_rank = before.present? ? before.rank : (after.rank < RANK_MAXIMUM-1 ? after.rank + 1 : RANK_MAXIMUM)

    self.rank = after_rank + ((before_rank - after_rank) / 2.0)
    true
  end

  def rank_between!(after, before)
    self.rank_between(after, before) && save
  end

  private

  def ensure_dates
    now = DateTime.now
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
