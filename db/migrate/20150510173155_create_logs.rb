class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.belongs_to :ontology, index: true
      t.integer :msg_type
      t.string :from_code
      t.string :to_code
      t.belongs_to :user, index: true
      t.belongs_to :query, index: true

      t.timestamps null: false
    end
    add_foreign_key :logs, :ontologies
    add_foreign_key :logs, :users
    add_foreign_key :logs, :queries
  end
end
