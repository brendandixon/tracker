class ChangeRankToDouble < ActiveRecord::Migration
  def up
    change_column :tasks, :rank, :float, limit: 53
  end

  def down
  end
end
