class ReferentReference < ActiveRecord::Base
  attr_accessible :reference_id, :referent_id, :referent_type

  belongs_to :reference
  belongs_to :referent, polymorphic: true

  validates_presence_of :reference
  validates_presence_of :referent
end
