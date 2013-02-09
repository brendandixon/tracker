class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.integer :reference_type_id
      t.string :value

      t.timestamps
    end
    add_index :references, :reference_type_id
  end
end
