class ChangePointsToFibonacci < ActiveRecord::Migration
  def up
    Task.all.each do |t|
      t.points ||= 0
      case t.points
      when 0, 1, 2, 3 then next
      when 4 then t.points = 5
      when 5 then t.points = 8
      end
      t.save
    end
  end

  def down
  end
end
