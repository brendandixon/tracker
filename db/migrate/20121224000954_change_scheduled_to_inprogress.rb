class ChangeScheduledToInprogress < ActiveRecord::Migration
  def up
    Task.where(status: :scheduled).update_all(status: :in_progress)
  end

  def down
  end
end
