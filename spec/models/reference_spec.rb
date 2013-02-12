# == Schema Information
#
# Table name: references
#
#  id                :integer          not null, primary key
#  reference_type_id :integer
#  value             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Reference do
  pending "add some examples to (or delete) #{__FILE__}"
end
