class ChangeServicesToFeatures < ActiveRecord::Migration
  def up
    remove_index :services, :abbreviation
    remove_index :services, [:name, :abbreviation]
    remove_index :services, :name

    remove_index :supported_services, :service_id
    remove_index :supported_services, [:project_id, :service_id]
    remove_index :supported_services, :project_id
    
    rename_table :services, :features
    rename_table :supported_services, :supported_features
    
    rename_column :stories, :service_id, :feature_id
    rename_column :supported_features, :service_id, :feature_id

    add_column :supported_features, :status, :string

    create_table :categories do |t|
      t.column :name, :string, null: false
      t.timestamps
    end
    add_index :categories, :name, unique: true

    remove_column :features, :name
    rename_column :features, :abbreviation, :name

    add_column :features, :category_id, :integer

    add_index :features, :name, unique: true
    add_index :features, :category_id

    add_index :supported_features, :feature_id
    add_index :supported_features, [:feature_id, :project_id], unique: true
    add_index :supported_features, :project_id
    add_index :supported_features, :status
  end

  def down
  end
end
