class Reference < ActiveRecord::Base
  attr_accessible :reference_type_id, :value

  belongs_to :reference_type
  has_many :referent_references, dependent: :destroy

  validates_presence_of :reference_type
  validates_presence_of :value

  def url_for
    self.reference_type.present? ? self.reference_type.url_for(self.value) : self.value
  end
end
