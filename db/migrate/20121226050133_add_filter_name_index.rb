class AddFilterNameIndex < ActiveRecord::Migration
  def up
    add_index :filters, :name
  end

  def down
  end
end
