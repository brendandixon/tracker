# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  story_id       :integer
#  project_id     :integer
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  title          :string(255)
#  rank           :float
#  points         :integer          default(0)
#  description    :text
#  start_date     :datetime
#  completed_date :datetime
#

require 'spec_helper'

describe Task do

  context "when first created" do
    its(:points) { should be(0) }
    its(:project) { should be_blank }
    its(:rank) { should be_blank }
    its(:status) { should be(:pending) }
    its(:story) { should be_blank }
    its(:title) { should be_blank }
    it('should be invalid') { should_not be_valid }
  end

  describe '#ClassMethods' do
  end

  describe '#Validations' do
  end

  describe '#scopes' do
  end

  describe '#members' do

    describe '#status' do
      subject { build(:task) }

      it 'should move from pending to in_progress' do
        subject.advance!
        subject.status.should be(:in_progress)
      end

      it 'should move from in_progress to completed' do
        subject.status = :in_progress
        subject.advance!
        subject.status.should be(:completed)
      end

      it 'should not move past completed' do
        subject.status = :completed
        subject.status.should be(:completed)
      end
    end

  end

end
