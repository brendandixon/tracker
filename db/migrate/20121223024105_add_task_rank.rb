class AddTaskRank < ActiveRecord::Migration
  def up
    add_column :tasks, :rank, :float
    add_index :tasks, :rank
  end

  def down
    remove_column :tasks, :rank
  end
end
