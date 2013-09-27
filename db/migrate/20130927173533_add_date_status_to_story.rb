class AddDateStatusToStory < ActiveRecord::Migration
  def change
    add_column :stories, :date_status, :string, default: 'planned'
  end
end
