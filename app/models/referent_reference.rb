# == Schema Information
#
# Table name: referent_references
#
#  id            :integer          not null, primary key
#  referent_id   :integer
#  referent_type :string(255)
#  reference_id  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ReferentReference < ActiveRecord::Base
  attr_accessible :reference_id, :referent_id, :referent_type

  belongs_to :reference, dependent: :destroy
  belongs_to :referent, polymorphic: true

  validates_presence_of :reference
  validates_presence_of :referent
end
