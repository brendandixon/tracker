# == Schema Information
#
# Table name: filters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  content    :text
#  area       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

require 'spec_helper'

describe Filter do
  pending "add some examples to (or delete) #{__FILE__}"
end
