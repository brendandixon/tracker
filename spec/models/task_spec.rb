# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  project_id :integer
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  title      :string(255)
#

require 'spec_helper'

describe Task do
  pending "add some examples to (or delete) #{__FILE__}"
end
