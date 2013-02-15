class DefaultFeatureState < ActiveRecord::Migration
  def up
    Project.supported.each do |project|
      FeatureProject.ensure_project_features(project)
    end
  end

  def down
  end
end
