class RenameFeatureId < ActiveRecord::Migration
  def up
    rename_column :tasks, :feature_id, :story_id
  end

  def down
  end
end
