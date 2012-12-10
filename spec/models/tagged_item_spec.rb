# == Schema Information
#
# Table name: tagged_items
#
#  id            :integer          not null, primary key
#  tag_id        :integer
#  taggable_id   :integer
#  taggable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe TaggedItem do
  pending "add some examples to (or delete) #{__FILE__}"
end
