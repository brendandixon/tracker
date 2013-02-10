class DropContactUsNumber < ActiveRecord::Migration
  def up
    remove_column :stories, :contact_us_number
  end

  def down
  end
end
