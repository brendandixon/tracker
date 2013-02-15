class RenameSupportedFeatures < ActiveRecord::Migration
  def up
    rename_table :supported_features, :feature_projects
  end

  def down
  end
end
