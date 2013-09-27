# == Schema Information
#
# Table name: stories
#
#  id           :integer          not null, primary key
#  release_date :datetime
#  title        :string(255)
#  feature_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  date_status  :string(255)      default("planned")
#

require 'spec_helper'

describe Story do
  pending "add some examples to (or delete) #{__FILE__}"
end
