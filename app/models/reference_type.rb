# == Schema Information
#
# Table name: reference_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  url_pattern :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deprecated  :boolean          default(FALSE)
#  tip         :string(255)
#

class ReferenceType < ActiveRecord::Base
  include CacheCleanser

  VALUE_MARKER = ':value:'
  
  attr_accessible :name, :url_pattern, :deprecated, :tip

  has_many :references, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :with_name, lambda{|name| where(name: name)}

  scope :in_name_order, lambda{|dir = 'ASC'| order("reference_types.name #{dir}")}
  scope :is_active, where(deprecated: false)
  
  class<<self
    def active
      @active ||= ReferenceType.in_name_order.is_active.all
    end

    def active_types
      @active_types ||= [['-', '']] + ReferenceType.active.map{|rt| [ rt.name, rt.id, {'data-tip' => rt.tip} ] }
    end

    def all_types
      @all_types ||= [['-', '']] + ReferenceType.in_name_order.all.map{|rt| [ rt.name, rt.id, {'data-tip' => rt.tip} ] }
    end
    
    def refresh_cache
      @active = nil
      @active_types = nil
      @all_types = nil
    end
  end

  def highlight_url_pattern(open = nil, close = nil)
    self.url_pattern.blank? ? nil : self.url_pattern.gsub(/#{VALUE_MARKER}/, "#{open}#{VALUE_MARKER}#{close}")
  end

  def linkable?
    self.url_pattern.present?
  end

  def url_for(value)
    self.url_pattern.present? ? self.url_pattern.gsub(/#{VALUE_MARKER}/, value) : value
  end

end
