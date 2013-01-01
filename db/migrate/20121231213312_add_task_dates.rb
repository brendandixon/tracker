class AddTaskDates < ActiveRecord::Migration
  def up
    add_column :tasks, :start_date, :datetime
    add_column :tasks, :completed_date, :datetime
  end

  def down
  end
end
