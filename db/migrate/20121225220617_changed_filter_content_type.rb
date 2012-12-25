class ChangedFilterContentType < ActiveRecord::Migration
  def up
    change_column :filters, :content, :text
  end

  def down
  end
end
