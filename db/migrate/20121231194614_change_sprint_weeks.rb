class ChangeSprintWeeks < ActiveRecord::Migration
  def up
    rename_column :teams, :sprint_weeks, :iteration
    change_column :teams, :iteration, :integer, default: 1
  end

  def down
  end
end
