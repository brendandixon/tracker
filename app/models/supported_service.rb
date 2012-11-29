# == Schema Information
#
# Table name: supported_services
#
#  id         :integer          not null, primary key
#  project_id :integer
#  service_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SupportedService < ActiveRecord::Base
  attr_accessible :project_id, :service_id
  
  belongs_to :project
  belongs_to :service
end
