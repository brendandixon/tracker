class SetDateState < ActiveRecord::Migration
  def up
    rename_column :stories, :date_status, :release_date_status
    
    Story.where('release_date IS NOT NULL').update_all(release_date_status: 'planned')
    Story.where('release_date IS NULL').update_all(release_date_status: 'unknown')
  end

  def down
  end
end
