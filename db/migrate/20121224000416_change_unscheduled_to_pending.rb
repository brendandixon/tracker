class ChangeUnscheduledToPending < ActiveRecord::Migration
  def up
    Task.where(status: :unscheduled).update_all(status: :pending)
  end

  def down
  end
end
