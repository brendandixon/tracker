class AddReferenceTip < ActiveRecord::Migration
  def up
    add_column :reference_types, :tip, :string
  end

  def down
  end
end
