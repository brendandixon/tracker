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

  POINTS = [0, 1, 2, 3, 5, 8]
  DEFAULT_POINTS = 2

  attr_accessible :completed_date, :description, :points, :project_id, :start_date, :status, :story_id, :title
    
  belongs_to :story
  has_one :feature, through: :story
  belongs_to :project
  has_many :teams, through: :project

  after_initialize :ensure_initial
  before_save :ensure_rank  
  before_validation :ensure_dates
  before_validation :ensure_title

  validate :has_title_or_story
  validates_inclusion_of :points, in: POINTS
  validates_presence_of :project
  validates_inclusion_of :status, in: ALL_STATES

  scope :for_iteration, lambda{|iteration_start_date = (DateTime.now - 5.years)| includes(:project, :feature).completed_on_or_after(iteration_start_date).in_iteration_order('ASC').uniq }
  
  scope :for_projects, lambda {|projects| where(project_id: projects)}
  scope :for_features, lambda{|features| joins(:story).where(stories: {feature_id: features})}
  scope :for_stories, lambda {|stories| where(story_id: stories)}
  scope :for_teams, lambda{|teams| joins(:teams).where(teams: {id: teams})}

  scope :completed_on_or_after, lambda{|date| where("(tasks.status = ? AND tasks.completed_date >= ?) OR tasks.status <> ?", :completed, date, :completed)}

  scope :at_least_points, lambda{|points| where("points >= ?", points)}
  scope :no_more_points, lambda{|points| where("points <= ?", points)}

  scope :after_rank, lambda{|rank| where("rank > ?", rank)}
  scope :before_rank, lambda{|rank| where("rank < ?", rank)}
  
  scope :pick_rank, select(:rank)

  scope :in_completed_order, lambda{|dir = 'ASC'| order("completed_date #{dir}")}
  scope :in_feature_order, lambda{|dir = 'ASC'| order("features.name #{dir}")}
  scope :in_point_order, lambda{|dir = 'ASC'| order("points #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| order("projects.name #{dir}")}
  scope :in_rank_order, lambda{|dir = 'ASC'| order("rank #{dir}")}
  scope :in_started_order, lambda{|dir = 'ASC'| order("start_date #{dir}")}
  scope :in_status_order, lambda{|dir = 'ASC'| order("status #{dir}")}
  scope :in_story_order, lambda{|dir = 'ASC'| order("stories.title #{dir}")}
  scope :in_title_order, lambda{|dir = 'ASC'| order("tasks.title #{dir}")}

  scope :in_iteration_order, lambda{|dir = 'ASC'| in_status_order(dir).in_completed_order(dir).in_started_order(dir).in_rank_order(dir) }
  
  StatusScopes::ALL_STATES.each do |s|
    class_eval <<-EOM
      def #{s}?
        self.status == '#{s}'
      end
      def #{s}!
        self.status = '#{s}'
        self.save unless self.new_record?
      end
    EOM
  end
  
  class<<self

    def all_points
      @all_points ||= [['-', '']] + Task::POINTS.map{|p| [p, p]}
    end
    
    def ensure_story_tasks(story)
      story.feature.projects.each do |project|
        next if Task.for_stories(story).for_projects(project).exists?
        Task.create(story_id:story.id, points: DEFAULT_POINTS, project_id:project.id, status: :pending)
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
    case self.status
    when 'pending' then 'in_progress'
    when 'in_progress' then 'completed'
    else self.status
    end
  end
  
  def title
    read_attribute(:title) || (self.story.present? && self.story.title) || nil
  end

  def ensure_rank
    return unless self.rank.blank?

    query = Task
    query = query.where("tasks.id <> ?", self.id) unless self.new_record?

    self.rank = if self.completed? || self.in_progress?
                  sibling = query.in_rank_order.in_state(self.status).pick_rank.limit(1).first
                  sibling.present? ? [sibling.rank, RANK_MAXIMUM-1].min + 1 : 1
                else
                  sibling = query.in_rank_order.pending.pick_rank.limit(1).first
                  sibling.present? ? [RANK_MINIMUM+1, sibling.rank].max - 1 : 1
                end
  end

  def rank_between(after, before)
    query = Task
    query = query.where("tasks.id <> ?", self.id) unless self.new_record?
    
    after = (query.pick_rank.find(after) rescue nil) unless after.blank? || after.is_a?(Task)
    before = (query.pick_rank.find(before) rescue nil) unless before.blank? || before.is_a?(Task)

    return false if after.blank? && before.blank?

    if after.blank?
      after = query.in_state(self.status).in_rank_order('DESC').before_rank(before.rank).pick_rank.limit(1).first
    elsif before.blank?
      before = query.in_state(self.status).in_rank_order.after_rank(after.rank).pick_rank.limit(1).first
    end

    after_rank = after.present? ? after.rank : [RANK_MINIMUM+2, before.rank].max - 2
    before_rank = before.present? ? before.rank : [RANK_MAXIMUM-2, after.rank].min + 2

    self.rank = after_rank + ((before_rank - after_rank) / 2.0)
    true
  end

  def rank_between!(after, before)
    self.rank_between(after, before) && save
  end

  def to_s
    self.feature.present? ? "#{self.title} (#{self.feature.name})" : self.title
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
      self.points ||= DEFAULT_POINTS
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
