class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :name
      t.string :content
      t.string :scope

      t.timestamps
    end
    add_index :filters, :scope
  end
end
