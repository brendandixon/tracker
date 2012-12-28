# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  velocity    :integer
#  sprint_days :integer          default(7)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Team do
  pending "add some examples to (or delete) #{__FILE__}"
end
