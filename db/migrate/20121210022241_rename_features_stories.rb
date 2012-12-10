class RenameFeaturesStories < ActiveRecord::Migration
  def up
    rename_table :stories, :tasks
    rename_table :features, :stories
  end

  def down
  end
end
