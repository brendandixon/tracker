class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :velocity
      t.integer :sprint_days

      t.timestamps
    end
    add_index :teams, :name
  end
end
