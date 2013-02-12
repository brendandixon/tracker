# == Schema Information
#
# Table name: references
#
#  id                :integer          not null, primary key
#  reference_type_id :integer
#  value             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Reference < ActiveRecord::Base
  attr_accessible :reference_type_id, :value

  belongs_to :reference_type
  has_many :referent_references, dependent: :destroy

  validates_presence_of :reference_type
  validates_presence_of :value

  def linkable?
    self.reference_type.present? && self.reference_type.linkable?
  end

  def url_for
    self.reference_type.present? ? self.reference_type.url_for(self.value) : self.value
  end

  def to_s
    self.reference_type.present? ? "#{self.reference_type.name} #{self.value}" : self.value
  end
end
