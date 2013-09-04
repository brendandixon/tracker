class AddDeprecatedReferenceFlag < ActiveRecord::Migration
  def up
    add_column :reference_types, :deprecated, :boolean, :default => false
  end

  def down
  end
end
