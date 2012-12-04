# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  abbreviation :string(255)
#

class Service < ActiveRecord::Base
  attr_accessible :name, :abbreviation

  has_many :features, dependent: :destroy
  has_many :supported_services, dependent: :destroy
  has_many :projects, through: :supported_services
  
  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :abbreviation
  validates_uniqueness_of :abbreviation
  
  scope :with_abbreviation, lambda {|abbreviation| where(abbreviation: abbreviation)}
  scope :with_name, lambda {|name| where(name: name)}

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}
  scope :in_service_order, lambda{|dir = 'ASC'| order("abbreviation #{dir}")}
  
  class<<self
    def active
      @active ||= Service.in_service_order.all
    end
  end

end
