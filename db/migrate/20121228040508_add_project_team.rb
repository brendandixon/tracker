class AddProjectTeam < ActiveRecord::Migration
  def up
    add_column :projects, :team_id, :integer
  end

  def down
  end
end
