# == Schema Information
#
# Table name: projects_services
#
#  id              :integer          not null, primary key
#  project_id          :integer
#  service_id      :integer
#  service_version :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe ProjectsServices do
  pending "add some examples to (or delete) #{__FILE__}"
end
