class Filter < ActiveRecord::Base
  attr_accessible :area, :content, :name

  before_validation :ensure_content

  validates_presence_of :area
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :area

  scope :for_area, lambda {|area| where(area: area) }

  def to_hash
    self.attributes.reject{|k, v| [:created_at, :updated_at].include?(k.to_sym) }
  end

  private

  def ensure_content
    self.content ||= {}
  end

end
