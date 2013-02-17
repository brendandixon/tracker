# == Schema Information
#
# Table name: feature_projects
#
#  id         :integer          not null, primary key
#  project_id :integer
#  feature_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :string(255)
#

class FeatureProject < ActiveRecord::Base
  attr_accessible :feature_id, :project_id, :status

  ALL_STATES = ['completed', 'in_progress', 'pending', 'unsupported']
  ALL_STATES_UI_ORDERED = ALL_STATES.reverse

  belongs_to :project
  belongs_to :feature

  validates_inclusion_of :status, in: ALL_STATES, allow_blank: true

  scope :for_feature, lambda{|feature| where(feature_id: feature.is_a?(Feature) ? feature.id : feature)}

  scope :in_feature_order, lambda{|dir = 'ASC'| includes(:feature).order("features.name #{dir}")}
  scope :in_project_order, lambda{|dir = 'ASC'| includes(:project).order("projects.name #{dir}")}

  ALL_STATES.each do |s|
    class_eval <<-EOM
      def #{s}?
        self.status == '#{s}'
      end
      def #{s}!
        self.status = '#{s}'
        self.save unless self.new_record?
      end
    EOM
  end

  class<<self

    def ensure_feature_projects(feature)
      Project.includes(:feature_projects).supported.each do |project|
        next if project.feature_projects.find{|feature_project| feature_project.feature_id == feature.id}
        FeatureProject.create(feature_id: feature.id, project_id: project.id, status: 'unsupported')
      end
    end

    def ensure_project_features(project)
      Feature.includes(:feature_projects).each do |feature|
        next if feature.feature_projects.find{|feature_project| feature_project.project_id == project.id}
        FeatureProject.create(feature_id: feature.id, project_id: project.id, status: 'unsupported')
      end
    end

  end

  def in_state?(status)
    self.status == status
  end

end
