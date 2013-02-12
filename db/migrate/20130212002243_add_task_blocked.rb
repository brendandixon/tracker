class AddTaskBlocked < ActiveRecord::Migration
  def up
    add_column :tasks, :blocked, :boolean
  end

  def down
  end
end
