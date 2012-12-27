class AddTaskPoints < ActiveRecord::Migration
  def up
    add_column :tasks, :points, :integer, default: 0
    add_column :tasks, :description, :text
  end

  def down
  end
end
