# == Schema Information
#
# Table name: referent_references
#
#  id            :integer          not null, primary key
#  referent_id   :integer
#  referent_type :string(255)
#  reference_id  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe ReferentReference do
  pending "add some examples to (or delete) #{__FILE__}"
end
