class RankTasks < ActiveRecord::Migration
  def up
    tasks = Task.in_rank_order('DESC')
    rank = tasks.count
    tasks.each do |task|
      task.update_column(:rank, rank)
      rank -= 1
    end
  end

  def down
  end
end
