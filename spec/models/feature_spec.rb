# == Schema Information
#
# Table name: features
#
#  id                :integer          not null, primary key
#  release_date      :datetime
#  title             :string(255)
#  service_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contact_us_number :integer
#

require 'spec_helper'

describe Feature do
  pending "add some examples to (or delete) #{__FILE__}"
end
