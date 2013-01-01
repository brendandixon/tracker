class RenameSprintDays < ActiveRecord::Migration
  def up
    rename_column :teams, :sprint_days, :sprint_weeks
  end

  def down
  end
end
