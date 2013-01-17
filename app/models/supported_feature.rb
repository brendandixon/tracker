# == Schema Information
#
# Table name: supported_features
#
#  id         :integer          not null, primary key
#  project_id :integer
#  feature_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :string(255)
#

class SupportedFeature < ActiveRecord::Base
  attr_accessible :feature_id, :project_id, :status

  ALL_STATES = [:completed, :in_progress, :pending, :unsupported]

  belongs_to :project
  belongs_to :feature
  
  symbolize :status

  validates_inclusion_of :status, in: ALL_STATES, allow_blank: true
end
