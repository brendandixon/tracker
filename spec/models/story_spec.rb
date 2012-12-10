# == Schema Information
#
# Table name: stories
#
#  id                :integer          not null, primary key
#  release_date      :datetime
#  title             :string(255)
#  service_id        :integer
#  contact_us_number :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Story do
  pending "add some examples to (or delete) #{__FILE__}"
end
