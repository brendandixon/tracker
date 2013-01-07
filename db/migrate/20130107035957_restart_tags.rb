class RestartTags < ActiveRecord::Migration
  def up
    drop_table :tagged_items
    drop_table :tags
  end

  def down
  end
end
