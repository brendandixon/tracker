class CreateReferentReferences < ActiveRecord::Migration
  def change
    create_table :referent_references do |t|
      t.integer :referent_id
      t.string :referent_type
      t.integer :reference_id

      t.timestamps
    end
    add_index :referent_references, [:referent_id, :referent_type, :reference_id], unique: true, name: 'referent_unique_reference'
    add_index :referent_references, [:referent_id, :referent_type]
    add_index :referent_references, :reference_id
  end
end
