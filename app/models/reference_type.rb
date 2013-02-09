class ReferenceType < ActiveRecord::Base
  VALUE_MARKER = ':value:'
  
  attr_accessible :name, :url_pattern

  has_many :references, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :with_name, lambda{|name| where(name: name)}

  scope :in_name_order, lambda{|dir = 'ASC'| order("reference_types.name #{dir}")}

  def highlight_url_pattern(open = nil, close = nil)
    self.url_pattern.blank? ? nil : self.url_pattern.gsub(/#{VALUE_MARKER}/, "#{open}#{VALUE_MARKER}#{close}")
  end

  def url_for(value)
    self.url_pattern.present? ? self.url_pattern.gsub(/#{VALUE_MARKER}/, value) : value
  end

end
