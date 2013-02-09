class CreateReferenceTypes < ActiveRecord::Migration
  def change
    create_table :reference_types do |t|
      t.string :name
      t.string :url_pattern

      t.timestamps
    end
    add_index :reference_types, :name, unique: true
  end
end
