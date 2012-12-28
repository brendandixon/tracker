class AddTeamDefaults < ActiveRecord::Migration
  def up
    change_column :teams, :sprint_days, :integer, default: 7
  end

  def down
  end
end
