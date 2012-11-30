# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Project < ActiveRecord::Base
  ALL = [
    'Java',
    '.NET',
    'Python',
    'PHP',
    'PHPv2',
    'Ruby',
    'JavaScript',
    'iOS',
    'Android'
  ]

  attr_accessible :name, :services

  has_many :supported_services, dependent: :destroy
  has_many :services, through: :supported_services

  has_many :stories, dependent: :destroy
  has_many :features, through: :stories
  
  validates_presence_of :name
  
  scope :with_name, lambda {|name| where(name: name) }
  
  scope :in_name_order, order('name ASC')

  class<<self
    ALL.each do |project|
      project_symbol = project.downcase.gsub(/[^\w]/,'')
      class_eval <<-METHODS
        def #{project_symbol}
          @#{project_symbol} ||= self.with_name('#{project}').first
        end
      METHODS
    end

    def active
      @active ||= self.in_name_order.all
    end
  end
end
