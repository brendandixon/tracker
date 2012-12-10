# == Schema Information
#
# Table name: tagged_items
#
#  id            :integer          not null, primary key
#  tag_id        :integer
#  taggable_id   :integer
#  taggable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TaggedItem < ActiveRecord::Base
  attr_accessible :tag_id, :taggable_id, :taggable_type
  
  has_many :taggables
  belongs_to :tag
end
