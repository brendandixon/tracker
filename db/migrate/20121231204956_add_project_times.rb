class AddProjectTimes < ActiveRecord::Migration
  def up
    add_column :projects, :start_date, :datetime
    add_column :projects, :end_date, :datetime
  end

  def down
  end
end
