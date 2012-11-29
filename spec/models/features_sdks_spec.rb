# == Schema Information
#
# Table name: features_projects
#
#  id         :integer          not null, primary key
#  feature_id :integer
#  project_id     :integer
#  status     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  version    :text
#

require 'spec_helper'

describe FeaturesProject do
  pending "add some examples to (or delete) #{__FILE__}"
end
