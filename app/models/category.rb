# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ActiveRecord::Base
  include CacheCleanser
  
  attr_accessible :name

  has_many :features
  
  validates_presence_of :name
  validates_uniqueness_of :name

  scope :with_name, lambda{|name| where(name: name)}

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}
  
  class<<self
    def active
      @active ||= Category.in_name_order.all
    end
    
    def all_categories
      @all_categories ||= [['-', '']] + Category.active.map{|s| [ s.name, s.id ] }
    end
    
    def refresh_cache
      @active = nil
      @all_categories = nil
    end
  end

end
