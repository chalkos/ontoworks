class CreateOntologies < ActiveRecord::Migration
  def change
    create_table :ontologies do |t|
      t.string :name, limit: 255, null: false
      t.string :code, limit: 255, null: false
      t.boolean :unlisted, default: false, null: false
      t.boolean :extendable, default: false, null: false
      t.datetime :expires, null: false

      t.timestamps null: false
    end
    add_index :ontologies, :code, :unique => true
  end
end
