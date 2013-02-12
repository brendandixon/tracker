class AddFilterOwner < ActiveRecord::Migration
  def up
    add_column :filters, :user_id, :integer
    add_index :filters, :user_id
  end

  def down
  end
end
