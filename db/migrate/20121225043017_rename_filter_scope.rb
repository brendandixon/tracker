class RenameFilterScope < ActiveRecord::Migration
  def up
    rename_column :filters, :scope, :area
  end

  def down
  end
end
