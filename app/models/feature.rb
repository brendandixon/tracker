# == Schema Information
#
# Table name: features
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#

class Feature < ActiveRecord::Base
  include CacheCleanser
  
  attr_accessible :name, :category_id

  has_many :stories, dependent: :destroy
  has_many :feature_projects, dependent: :destroy
  has_many :projects, through: :feature_projects

  belongs_to :category

  after_create :ensure_projects
  
  validates_presence_of :name
  validates_uniqueness_of :name

  scope :for_category, lambda{|category_id| where(category_id: category_id)}
  
  scope :with_name, lambda{|name| where(name: name)}

  scope :in_category_order, lambda{|dir = 'ASC'| order("categories.name #{dir}")}
  scope :in_name_order, lambda{|dir = 'ASC'| order("features.name #{dir}")}
  
  class<<self
    def active
      @active ||= Feature.in_name_order.all
    end
    
    def all_features
      @all_features ||= [['-', '']] + Feature.active.map{|s| [ s.name, s.id ] }
    end
    
    def refresh_cache
      @active = nil
      @all_features = nil
    end
  end

  private

  def ensure_projects
    FeatureProject.ensure_feature_projects(self)
  end

end
