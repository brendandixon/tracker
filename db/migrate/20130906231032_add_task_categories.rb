class AddTaskCategories < ActiveRecord::Migration
  def up
    add_column :tasks, :category, :string, default: 'development'
    Task.where(category: nil).update_all(category: 'development')
  end

  def down
  end
end
