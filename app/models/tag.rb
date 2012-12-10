# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  category   :string(255)
#  scope      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ActiveRecord::Base
  attr_accessible :category, :name, :scope
  
  CATEGORIES = [:general, :services]
  SCOPES = [:all, :stories, :tasks]

  has_many :tagged_items
  has_many :taggables, through: :tagged_items
  
  symbolize :category, :scope

  validates_presence_of :name
  validates_inclusion_of :category, in: CATEGORIES
  validates_inclusion_of :scope, in: SCOPES

  scope :for_category, lambda{|category| where(category: category)}
  scope :for_scope, lambda{|scope| where(scope: scope)}
  
  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}
end
