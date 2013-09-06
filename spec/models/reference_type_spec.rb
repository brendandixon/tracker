# == Schema Information
#
# Table name: reference_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  url_pattern :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deprecated  :boolean          default(FALSE)
#  tip         :string(255)
#

require 'spec_helper'

describe ReferenceType do
  pending "add some examples to (or delete) #{__FILE__}"
end
