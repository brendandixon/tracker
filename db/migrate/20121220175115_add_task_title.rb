class AddTaskTitle < ActiveRecord::Migration
  def up
    add_column :tasks, :title, :string
  end

  def down
    drop_column :tasks, :title
  end
end
